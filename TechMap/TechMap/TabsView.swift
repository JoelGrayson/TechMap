//
//  TabsView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI
import FirebaseFirestore

struct TabsView: View {
    @State private var firebaseVM = FirebaseVM()
    @FirestoreQuery(
        collectionPath: "companies",
    )
    var companies: [Company]
    
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
