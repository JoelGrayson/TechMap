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
                .padding(.top)
            
            if let settings = rawSettings.first {
                // Marker size
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
                
                
                // Transportation option
                HStack {
                    Text("Transportation Method")
                    Spacer()
                    Picker(
                        "Transportation Method",
                        selection: .init(get: { settings.transportationMethod }, set: { newValue in
                            settings.transportationMethod = newValue
                            try? modelContext.save()
                        })
                    ) {
                        Text("Walking")
                            .tag(Settings.TransportMethod.walking)
                        Text("Biking")
                            .tag(Settings.TransportMethod.biking)
                        Text("Driving")
                            .tag(Settings.TransportMethod.driving)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
                
                
                // Reset button
                HStack {
                    Spacer()
                    Button("Reset Settings", systemImage: "arrow.counterclockwise.circle") {
                        settings.markerSize = Settings.defaultSettings.markerSize
                        settings.transportationMethod = Settings.defaultSettings.transportationMethod
                    }
                    .tint(.red)
                    .buttonStyle(.bordered)
                    Spacer()
                }
                
            } else {
                Text("Settings has not been configured yet.")
            }
            
            Spacer()
            
            Section {
                if let url = URL(string: "https://forms.gle/WvifgC66xR2g1Y5p6") {
                    Link(destination: url) {
                        Text("Leave feedback or report a bug")
                    }
                } else {
                    Text("If you have any feedback or there is a bug, feel free to email joel@joelgrayson.com")
                }
            }
        }
        .padding()
    }
}

