//
//  SettingsTabView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI
import Kingfisher
import AuthenticationServices

import SwiftData

//TODO: option to change from Bay Area to NYC

struct SettingsTabView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    var firebaseVM: FirebaseVM
    var locationVM: LocationVM
    
    @Query var rawSettings: [Settings]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Account")
                .sectionTitle()
            
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
                // Continue with Google button
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
                        Text("Continue with Google") //continue means sign in if account exists and sign up if no account exists yet
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                    .frame(maxWidth: .infinity)
                    //.frame(height: Styles.signInButtonHeight)
                }
                .buttonStyle(.bordered)
                
                
                // Continue with Apple button
                SignInWithAppleButton(.continue) { req in
                    firebaseVM.handleSignInWithAppleRequest(req)
                } onCompletion: { res in
                    firebaseVM.handleSignInWithAppleCompletion(res)
                }
                .frame(height: Styles.signInButtonHeight)
            }
            
            
            Text("General")
                .sectionTitle()
            
            if let settings = rawSettings.first {
                HStack {
                    Text("Marker Size")
                    Spacer()
                    Picker(
                        "Marker Size",
                        selection: .init(get: { settings.markerSize }, set: { newValue in
                            settings.markerSize = newValue
                            try? modelContext.save()
                        })
                    ) {
                        Text("Small")
                            .tag(Settings.MarkerSize.small)
                        Text("Normal")
                            .tag(Settings.MarkerSize.normal)
                        Text("Large")
                            .tag(Settings.MarkerSize.large)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
            } else {
                Text("Settings has not been configured yet.")
            }
        }
        .padding()
    }
}

