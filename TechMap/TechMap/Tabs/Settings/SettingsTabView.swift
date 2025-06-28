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
        if let email = firebaseVM.email, let name = firebaseVM.name, let photoURL = firebaseVM.photoURL {
            HStack {
                KFImage(photoURL)
                Text("Signed in as \(name) <\(email)>")
            }
            Button("Sign Out") {
                firebaseVM.signOut()
            }
            .buttonStyle(.bordered)
        }
        if !firebaseVM.isSignedIn {
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
        }
    }
}

#Preview {
    SettingsTabView(firebaseVM: MockData.firebaseVM)
}
