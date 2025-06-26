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
class AuthVM {
    var isSignedIn: Bool = false
    var errorMessage: String?
    
    var email: String?
    var name: String?
    var photoURL: URL?
    var uid: String?
    
    init() { }
    
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
            email = firebaseUser.email
            name = firebaseUser.displayName
            photoURL = firebaseUser.photoURL
            uid = firebaseUser.uid
            
            isSignedIn = true
            errorMessage = nil //no error
            return true
        } catch {
            print(error.localizedDescription)
            errorMessage = error.localizedDescription
            return false
        }
    }
}

