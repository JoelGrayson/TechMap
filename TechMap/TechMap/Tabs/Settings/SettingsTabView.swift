//
//  SettingsTabView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI
import Kingfisher
import AuthenticationServices
import CoreLocation
import MapKit
import SwiftData

struct SettingsTabView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    var firebaseVM: FirebaseVM
    var locationVM: LocationVM
    
    @Query var rawSettings: [Settings]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Account")
                        .sectionTitle()
                        .padding(.bottom)
                    
                    VStack(alignment: .center, spacing: Styles.settingsGapBetweenItems) {
                        if let errorMessage = firebaseVM.errorMessage {
                            Text("Auth error \(errorMessage)")
                        }
                        if firebaseVM.isSignedIn == .signedIn {
                            HStack {
                                if let photoURL = firebaseVM.photoURL {
                                    KFImage(photoURL)
                                        .resizable()
                                        .frame(maxWidth: Styles.profilePhotoSize, maxHeight: Styles.profilePhotoSize)
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
                            
                            NavigationLink("Manage Account", destination: MoreOptionsView(firebaseVM: firebaseVM))
                                .buttonStyle(.bordered)
                        }
                        
                        if firebaseVM.isSignedIn == .notSignedIn {
                            Text("Not signed in")
                        }
                        
                        if firebaseVM.isSignedIn != .signedIn {
                            // Message to sign in
                            HStack {
                                Text("Sign in/sign up to save your visited list and be able to sync them to multiple devices")
                                    .lineLimit(nil)
                                if firebaseVM.isSignedIn == .anonymouslySignedIn, let uid = firebaseVM.uid {
                                    NavigationLink(destination: Text("Currently signed in with guest UID \(uid)")) {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            
                            
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
                    }
                    .frame(maxWidth: .infinity)
                    
                    
                    Text("General")
                        .sectionTitle()
                        .padding(.top, Styles.settingsGapBetweenSections)
                    
                    // Location Services Prompt
                    let authStatus = CLLocationManager().authorizationStatus
                    if authStatus == .denied || authStatus == .notDetermined {
                        VStack(alignment: .center, spacing: 8) {
                            Text("Please enable location services to see where you are on the map")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Button(authStatus == .notDetermined ? "Enable Location Services" : "Open Settings") {
                                if authStatus == .notDetermined {
                                    locationVM.requestLocationPermission()
                                } else {
                                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(settingsUrl)
                                    }
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    if let settings = rawSettings.first {
                        VStack(spacing: Styles.settingsGapBetweenItems) {
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
                                .frame(maxWidth: 200)
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
                                    Text("Driving")
                                        .tag(Settings.TransportMethod.driving)
                                }
                                .pickerStyle(.segmented)
                                .labelsHidden()
                                .frame(maxWidth: 200)
                            }
                            
                            
                            // Only show headquarters
                            VStack {
                                HStack {
                                    Text("Only Show Headquarters")
                                    Spacer()
                                    Toggle(
                                        "Only Show Headquarters",
                                        isOn: Binding<Bool>(
                                            get: { settings.onlyShowHeadquarters },
                                            set: { newValue in
                                                settings.onlyShowHeadquarters = newValue
                                                try? modelContext.save()
                                            }
                                        )
                                    )
                                    .toggleStyle(.switch)
                                    .labelsHidden()
                                }
                                
                                if !settings.onlyShowHeadquarters {
                                    HStack {
                                        Text("Offices that aren't headquarters are surrounded by a dotted line like so:")
                                        .lineLimit(nil)
                                        JMarker(checked: false, imageName: "linkedin.com.jpg", selected: false, markerSize: .small, isHeadquarters: false)
                                    }
                                    .padding(.leading)
                                }
                            }
                            
                            // Play sound when checked
                            HStack {
                                Text("Play Sound When Checked")
                                Spacer()
                                Toggle(
                                    "Play Sound When Checked",
                                    isOn: Binding<Bool>(
                                        get: { settings.playSoundWhenChecked },
                                        set: { newValue in
                                            settings.playSoundWhenChecked = newValue
                                            try? modelContext.save()
                                        }
                                    )
                                )
                                .toggleStyle(.switch)
                                .labelsHidden()
                            }
                            
                            
                            // Reset button
                            HStack {
                                Spacer()
                                Button("Reset Settings", systemImage: "arrow.counterclockwise.circle") {
                                    settings.markerSize = Settings.defaultSettings.markerSize
                                    settings.transportationMethod = Settings.defaultSettings.transportationMethod
                                    settings.playSoundWhenChecked = Settings.defaultSettings.playSoundWhenChecked
                                }
                                .tint(.red)
                                .buttonStyle(.bordered)
                                Spacer()
                            }
                        }
                    } else {
                        Text("Settings has not been configured yet.")
                    }
                    
                    
                    Text("App Info")
                        .sectionTitle()
                        .padding(.top, Styles.settingsGapBetweenSections)
                    
                    VStack(spacing: Styles.settingsGapBetweenItems*0.7) {
                        if let url = URL(string: "https://joelgrayson.com/techmap") {
                            Link(destination: url) {
                                Text("Open Web Version")
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        HStack {
                            Spacer()
                            FeedbackButton()
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Text("Help by")
                            RatingButton()
                            Spacer()
                        }
                        
                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                            Text("TechMap Version \(version)")
                                .font(.caption)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

