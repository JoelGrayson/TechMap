//
//  CompanyDetails.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import SwiftUI
import CoreLocation
import MapKit
import SwiftData

struct CompanyDetails: View {
    @Binding var company: Company?
    let checks: [Check]
    let firebaseVM: FirebaseVM
    let locationVM: LocationVM
    let closable: Bool
    let onDirectionsRequested: ((Company) -> Void)?
    
    // Computed properties
    private var checked: Check? {
        associatedCheck(company: company, checks: checks)
    }
    private var hidden: Bool {
        company == nil
    }
    
    // Actions
    private func markAsVisited() {
        firebaseVM.addCheck(companyId: company?.id)
        if settings.playSoundWhenChecked {
            playSound(named: "check")
        }
    }
    private func uncheck() {
        firebaseVM.deleteCheck(companyId: company?.id)
    }
    
    @State private var distance: String?
    @State private var time: String?
    
    @Query var rawSettings: [Settings]
    var settings: Settings {
        rawSettings.first ?? Settings.defaultSettings
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                if let company {
                    HStack {
                        // Logo
                        InlineLogo(imageName: company.imageName)
                        
                        // Name
                        Text(company.name)
                        
                        Spacer()
                        
                        // Check/Uncheck button
                        if checked != nil {
                            Button("Uncheck") {
                                uncheck()
                            }
                            .buttonStyle(.bordered)
                        } else {
                            Button("Mark as Visited") {
                                markAsVisited()
                            }
                            .buttonStyle(.bordered)
                            .tint(Color.checked)
                        }
                        
                        // Close Button
                        if closable {
                            Button {
                                self.company = nil
                            } label: {
                                CloseIcon()
                            }
                        }
                    }
                    
                    HStack {
                        Image(systemName: "mappin")
                            .frame(width: Styles.charIconSize, height: Styles.charIconSize)
                        
                        // Address which is a link that opens in maps when clicked
                        Button {
                            openInMaps(lat: company.lat, lng: company.lng, name: company.name, address: company.address)
                        } label: {
                            Text(company.address)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    if let distance = locationVM.distance, let time = locationVM.time {
                        HStack {
                            // Walk icon
                            Image(systemName: settings.transportationMethod == .walking ? "figure.walk" : "car.fill")
                                .frame(width: Styles.charIconSize, height: Styles.charIconSize)
                            
                            // Distance like "5 min walk"
                            Text("\(time) \(settings.transportationMethod == .walking ? "walk" : "drive") (\(distance))")
                            
                            
                            Spacer()
                            // Directions button
                            if let onDirectionsRequested {
                                Button("Directions") {
                                    onDirectionsRequested(company)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                    
                    // If you visited, it tells you when you visited it
                    if let checked {
                        HStack {
                            Image(systemName: "checkmark")
                                .frame(width: Styles.charIconSize, height: Styles.charIconSize)
                            
                            Text("Visited on \(JDateFormatter.formatAbsolutely(checked.createdAt)) (\(JDateFormatter.formatRelatively(checked.createdAt)))")
                        }
                    }
                    
                    ScrollView {
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "info")
                                .frame(width: Styles.charIconSize, height: Styles.charIconSize)
                                .font(.body)
                            
                            Text(company.description)
                        }
                        
                        Button {
                            showSiteInApp(urlString: "https://en.wikipedia.org/wiki/\(company.wikipediaSlug)")
                        } label: {
                            HStack {
                                Image("wikipedia")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                
                                Text("Open its Wikipedia")
                            }
                        }
                    }
                    // .lineLimit(closable ? 8 : nil) //when closable, it is in its small form
                    
                }
            }
            .opacity(hidden ? 0 : 1)
            .padding()
        }
        .onAppear {
            locationVM.company = company
            locationVM.startTracking()
        }
        .onDisappear() {
            locationVM.company = nil
            locationVM.stopTracking()
        }
        .onChange(of: company) {
            locationVM.company = company
        }
    }
}

