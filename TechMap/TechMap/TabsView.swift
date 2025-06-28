//
//  TabsView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI
import FirebaseFirestore

struct TabsView: View {
    let firebaseVM: FirebaseVM
    
    @FirestoreQuery(collectionPath: "companies")
    var companies: [Company]
    
    @State private var checks: [Check] = []
    
    var body: some View {
        TabView {
            Tab("Map", systemImage: "mappin.circle.fill") {
                MapTabView(firebaseVM: firebaseVM, companies: companies, checks: checks)
            }
            Tab("List", systemImage: "list.bullet") {
                ListTabView(firebaseVM: firebaseVM, companies: companies, checks: checks)
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsTabView(firebaseVM: firebaseVM)
            }
        }
        .onAppear {
            loadChecks()
        }
        .onChange(of: firebaseVM.uid) {
            loadChecks()
        }
    }
    
    func loadChecks() {
        guard let uid = firebaseVM.uid else {
            print("UID not found when loading checks")
            return
        }
        let db = Firestore.firestore()
        db.collection("checkmarks")
            .whereField("userId", isEqualTo: uid)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching checks: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self.checks = documents.compactMap { document in
                    try? document.data(as: Check.self)
                }
            }
    }
}

