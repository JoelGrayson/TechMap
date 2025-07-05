//
//  FirebaseVM.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseFirestore

// for Continue with Apple
import CryptoKit
import AuthenticationServices

enum SignInState {
    case notSignedIn
    case anonymouslySignedIn
    case signedIn
}

@Observable
class FirebaseVM { //handles auth and firestore
    // Auth
    var isSignedIn: SignInState = .notSignedIn
    var errorMessage: String?
    
    var email: String?
    var name: String?
    var photoURL: URL?
    var uid: String?
    
    private var currentNonce: String?
    
    // Auth Functions
    func signInAnonymously() async {
        do {
            let result = try await Auth.auth().signInAnonymously()
            let uid = result.user.uid
            print("Signed in with UID", uid)
            self.uid = uid
            self.isSignedIn = .anonymouslySignedIn
        } catch {
            print("Could not sign in anonymously")
            print(error.localizedDescription)
        }
    }
    
    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No Google ClientID in Firebase config")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            print("Could not get root view controller")
            errorMessage = "Could not get root view controller"
            return false
        }
        
        do {
            // Get google credential
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                print("ERROR! Could not get token")
                return false
            }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            
            
            try await signInAndLinkIfNecessary(credential: credential)
            
            isSignedIn = .signedIn
            errorMessage = nil //no error
            return true
        } catch {
            print(error.localizedDescription)
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // Two Continue with Apple functions
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let failure) = result {
            errorMessage = failure.localizedDescription
            return
        }
        if case .success(let authorization) = result {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: a login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identify token.")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                let credential = OAuthProvider.credential(providerID: .apple, idToken: idTokenString, rawNonce: nonce)
                
                Task {
                    do {
                        try await signInAndLinkIfNecessary(credential: credential)
                        
                        isSignedIn = .signedIn
                        errorMessage = nil
                    } catch {
                        print("Error authenticating: \(error.localizedDescription)")
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    func signInAndLinkIfNecessary(credential: AuthCredential) async throws {
        // Sign in with Google and link anonymous account if possible
        if let currentUser = Auth.auth().currentUser, currentUser.isAnonymous {
            // Try to link the anonymous user to the Google account
            do {
                let result = try await currentUser.link(with: credential)
                setPropertiesFrom(user: result.user)
                print("Linked anonymous account to user")
            } catch {
                // If linking fails (credential already exists), handle based on credential type
                print("Linking failed, signing in directly: \(error.localizedDescription)")
                
                // Check if this is an Apple Sign-In credential causing duplicate error
                if let authError = error as NSError?, 
                   authError.code == AuthErrorCode.credentialAlreadyInUse.rawValue ||
                   authError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    
                    // For Apple Sign-In duplicate credential, we need to handle this differently
                    // The user is already signed in with this Apple ID, so we should just acknowledge that
                    print("Credential already in use - user is already signed in with this account")
                    
                    // Try to get the existing user info from the error
                    if let existingCredential = (authError.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential) {
                        do {
                            let oldUserId = currentUser.uid
                            let result = try await Auth.auth().signIn(with: existingCredential)
                            let newUserId = result.user.uid
                            
                            // Transfer checks from anonymous account to signed-in account
                            await transferChecks(from: oldUserId, to: newUserId)
                            
                            setPropertiesFrom(user: result.user)
                            print("Successfully signed in with existing credential")
                            return
                        } catch {
                            print("Failed to sign in with existing credential: \(error.localizedDescription)")
                        }
                    }
                    
                    // If we can't get the existing credential, throw an informative error
                    throw NSError(domain: "AuthError", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: "This Apple ID is already linked to another account. Please use a different sign-in method or contact support."
                    ])
                }
                
                // For other types of linking failures, try direct sign-in
                do {
                    let oldUserId = currentUser.uid
                    let result = try await Auth.auth().signIn(with: credential)
                    let newUserId = result.user.uid
                    
                    // Transfer checks from anonymous account to signed-in account
                    await transferChecks(from: oldUserId, to: newUserId)
                    
                    setPropertiesFrom(user: result.user)
                    print("Signed in with existing account with email \(result.user.email ?? "undefined")")
                } catch {
                    print("Error signing in after link failure: \(error.localizedDescription)")
                    throw error
                }
            }
        } else {
            // No current user or user is not anonymous - sign in directly
            let result = try await Auth.auth().signIn(with: credential)
            setPropertiesFrom(user: result.user)
            print("Signed in with account with email \(result.user.email ?? "undefined")")
        }
    }
    
    func setPropertiesFrom(user: User) {
        self.email = user.email
        self.name = user.displayName
        self.photoURL = user.photoURL
        self.uid = user.uid
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            reset()
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
    
    func checkAuthState() {
        let _ = Auth.auth().addStateDidChangeListener { auth, user in
            DispatchQueue.main.async {
                if let user = user {
                    print("Signed in with user with email \(user.email ?? "undefined") and uid \(user.uid)")
                    self.setPropertiesFrom(user: user)
                    if user.isAnonymous {
                        self.isSignedIn = .anonymouslySignedIn
                    } else {
                        self.isSignedIn = .signedIn
                    }
                } else {
                    print("Signing in anonymously")
                    Task {
                        await self.signInAnonymously()
                    }
                }
            }
        }
    }
    
    func reset() {
        isSignedIn = .notSignedIn
        errorMessage = nil
        email = nil
        name = nil
        photoURL = nil
        uid = nil
    }
    
    func transferChecks(from oldUserId: String, to newUserId: String) async {
        let db = Firestore.firestore()
        
        do {
            // Get all checks for the old user ID
            let snapshot = try await db.collection("checkmarks")
                .whereField("userId", isEqualTo: oldUserId)
                .getDocuments()
            
            guard !snapshot.documents.isEmpty else {
                print("No checks to transfer from anonymous account")
                return
            }
            
            print("Transferring \(snapshot.documents.count) checks from anonymous account to signed-in account")
            
            // Create new checkmarks with the new user ID (don't delete old ones)
            for document in snapshot.documents {
                do {
                    // Parse the existing check data
                    let existingCheck = try document.data(as: Check.self)
                    
                    // Create a new check with the new user ID
                    let newCheck = Check(
                        companyId: existingCheck.companyId,
                        userId: newUserId,
                        createdAt: existingCheck.createdAt,
                        device: existingCheck.device
                    )
                    
                    // Add the new check
                    try db.collection("checkmarks").addDocument(from: newCheck)
                    
                } catch {
                    print("Error transferring check \(document.documentID): \(error.localizedDescription)")
                }
            }
            
            print("Successfully transferred \(snapshot.documents.count) checks to new account")
            
        } catch {
            print("Error transferring checks: \(error.localizedDescription)")
        }
    }
    
    
    // Checks functions
    func addCheck(companyId: String?) {
        guard let uid = uid else {
            print("A user is required to add a check")
            return
        }
        guard let companyId else {
            print("companyId undefined. Ignoring add action.")
            return
        }
        
        let db = Firestore.firestore()
        let check = Check(companyId: companyId, userId: uid, createdAt: .now, device: Constants.deviceTypeMobile)
        
        do {
            try db
                .collection("checkmarks")
                .addDocument(from: check)
        } catch {
            print("Failed to add checkmarks: \(error)")
        }
    }
    
    func deleteCheck(companyId: String?) {
        guard let uid = uid else {
            print("A user is required to delete a check")
            return
        }
        guard let companyId else {
            print("companyId undefined. Ignoring delete action.")
            return
        }
        
        // Copied from ChatGPT
        let db = Firestore.firestore()
        db
            .collection("checkmarks")
            .whereField("userId", isEqualTo: uid)
            .whereField("companyId", isEqualTo: companyId)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                for doc in docs {
                    doc.reference.delete() { error in
                        print("Could not delete checkmark with companyId \(companyId) for uid \(uid)")
                    }
                }
            }
    }
}

