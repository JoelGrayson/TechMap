//
//  TabsView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI
import FirebaseFirestore

struct TabsView: View {
    @FirestoreQuery(collectionPath: "companies")
    var companies: [Company]
    
    @FirestoreQuery(
        collectionPath: "checks",
        predicates: [.where("userId", isEqualTo: firebaseVM.uid)]
    )
    var checks: [Check]
    
    var body: some View {
        TabView {
            Tab("Map", systemImage: "mappin.circle.fill") {
                MapTabView(firebaseVM: firebaseVM, companies: companies)
            }
            Tab("List", systemImage: "list.bullet") {
                ListTabView(firebaseVM: firebaseVM)
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsTabView(firebaseVM: firebaseVM)
            }
        }
    }
}

#Preview {
    TabsView()
}
