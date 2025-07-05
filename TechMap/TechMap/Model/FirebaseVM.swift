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
                // If linking fails (credential already exists), sign in directly
                print("Linking failed, signing in directly: \(error.localizedDescription)")
                let result = try await Auth.auth().signIn(with: credential)
                setPropertiesFrom(user: result.user)
                print("Signed in with existing Google account with email \(result.user.email ?? "undefined")")
            }
        } else {
            let result = try await Auth.auth().signIn(with: credential)
            setPropertiesFrom(user: result.user)
            print("Signed in with a blank slate account with UID \(result.user.uid)")
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
        let check = Check(companyId: companyId, userId: uid, createdAt: .now, device: "iphone app")
        
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

