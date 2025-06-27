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
    @State private var authVM = AuthVM()
    
    var body: some View {
        if let errorMessage = authVM.errorMessage {
            Text("Auth error \(errorMessage)")
        }
        if let email = authVM.email, let name = authVM.name, let photoURL = authVM.photoURL {
            HStack {
                KFImage(photoURL)
                Text("Signed in as \(name) <\(email)>")
            }
            Button("Sign Out") {
                authVM.signOut()
            }
            .buttonStyle(.bordered)
        }
        if !authVM.isSignedIn {
            Button {
                Task {
                    await authVM.signInWithGoogle()
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
    SettingsTabView()
}
