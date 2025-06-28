//
//  SettingsTabView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI
import Kingfisher

//TODO: option to change from Bay Area to NYC

struct SettingsTabView: View {
    @Environment(\.colorScheme) var colorScheme
    var firebaseVM: FirebaseVM
    
    var body: some View {
        if let errorMessage = firebaseVM.errorMessage {
            Text("Auth error \(errorMessage)")
        }
        if firebaseVM.isSignedIn == .signedIn {
            HStack {
                if let photoURL = firebaseVM.photoURL {
                    KFImage(photoURL)
                }
                if let email = firebaseVM.email {
                    if let name = firebaseVM.name {
                        Text("Signed in as \(name) <\(email)>")
                    } else {
                        Text("Signed in as \(email)")
                    }
                }
            }
            Button("Sign Out") {
                firebaseVM.signOut()
            }
            .buttonStyle(.bordered)
        }
        
        if firebaseVM.isSignedIn == .notSignedIn {
            Text("Not signed in")
        }
        if firebaseVM.isSignedIn == .anonymouslySignedIn, let uid = firebaseVM.uid {
            Text("Signed in with guest UID \(uid)")
        }
        if firebaseVM.isSignedIn != .signedIn {
            Button {
                Task {
                    await firebaseVM.signInWithGoogle()
                }
            } label: {
                HStack {
                    Image("google")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, alignment: .center)
                    Text("Sign in with Google")
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            // TODO: add a sign in with apple button
        }
    }
}

#Preview {
    SettingsTabView(firebaseVM: MockData.firebaseVM)
}
