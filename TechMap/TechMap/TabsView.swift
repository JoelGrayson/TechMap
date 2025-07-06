//
//  TabsView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI
import FirebaseFirestore
import SwiftData
import MapKit

struct TabsView: View {
    let firebaseVM: FirebaseVM
    @State private var locationVM = LocationVM()
    @Binding var selectedTab: String
    
    @FirestoreQuery(collectionPath: "companies")
    var rawCompanies: [Company]
    var companies: [Company] { //take into account settings
        rawCompanies
            .filter({ company in
                if settings.onlyShowHeadquarters {
                    return company.isHeadquarters //only show companies with isHeadquarters true
                } else {
                    return true //show all companies
                }
            })
    }
    
    @State private var checks: [Check] = []
    
    @Query var rawSettings: [Settings]
    var settings: Settings {
        rawSettings.first ?? Settings.defaultSettings
    }
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State var selectedCompany: Company?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Map", systemImage: Constants.mapIcon, value: Constants.mapTabValue) {
                MapTabView(firebaseVM: firebaseVM, locationVM: locationVM, companies: companies, checks: checks, selectedCompany: $selectedCompany, cameraPosition: $cameraPosition)
            }
            Tab("List", systemImage: "list.bullet", value: "List") {
                ListTabView(firebaseVM: firebaseVM, locationVM: locationVM, companies: companies, checks: checks, selectedCompany: $selectedCompany, selectedTab: $selectedTab, cameraPosition: $cameraPosition)
            }
            Tab("Settings", systemImage: "gearshape.fill", value: "Settings") {
                SettingsTabView(firebaseVM: firebaseVM, locationVM: locationVM)
            }
        }
        .onAppear {
            loadChecks()
            locationVM.settings = settings
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

