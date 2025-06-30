//
//  TechMapApp.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth

@main
struct TechMapApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            UserWrapper()
                .modelContainer(for: [Settings.self])
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        // uncomment the line below to use emulator
        // Auth.auth().useEmulator(withHost: "localhost", port: 9099)
        return true
    }
}
