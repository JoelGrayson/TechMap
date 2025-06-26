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
            TabsView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
