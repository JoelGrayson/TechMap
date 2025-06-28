//
//  AuthVM.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

@Observable
class FirebaseVM { //handles auth and firestore
    // Auth
    var isSignedIn: Bool = false
    var errorMessage: String?
    
    var email: String?
    var name: String?
    var photoURL: URL?
    var uid: String?
    
    
    // Checklists (Firestore)
    // TODO:
    
    
    init() {
        checkAuthState() //for persisting
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
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                print("ERROR! Could not get token")
                return false
            }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            setPropertiesFrom(user: firebaseUser)
            
            isSignedIn = true
            errorMessage = nil //no error
            return true
        } catch {
            print(error.localizedDescription)
            errorMessage = error.localizedDescription
            return false
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
                    self.setPropertiesFrom(user: user)
                }
            }
        }
    }
    
    func reset() {
        isSignedIn = false
        errorMessage = nil
        email = nil
        name = nil
        photoURL = nil
        uid = nil
    }
}

