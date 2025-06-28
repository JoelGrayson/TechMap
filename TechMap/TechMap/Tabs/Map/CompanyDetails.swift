//
//  CompanyDetails.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import SwiftUI

struct CompanyDetails: View {
    @Binding var company: Company?
    let checks: [Check]
    let firebaseVM: FirebaseVM
    let closable: Bool
    
    // Computed properties
    private var checked: Bool {
        companyChecked(company: company, checks: checks)
    }
    private var hidden: Bool {
        company == nil
    }
    
    // Actions
    private func markAsVisited() {
        firebaseVM.addCheck(companyId: company?.id)
        playSound(named: "check")
    }
    private func uncheck() {
        firebaseVM.deleteCheck(companyId: company?.id)
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
                        if checked {
                            Button("Uncheck") {
                                uncheck()
                            }
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
                        Button {
                            openInMaps(lat: company.lat, lng: company.lng, name: company.name, address: company.address)
                        } label: {
                            Text(company.address)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    HStack {
                        Image(systemName: "figure.walk")
                            .frame(width: Styles.charIconSize, height: Styles.charIconSize)
                        Text("5 min walk")
                        Spacer()
                        Button("Directions") {
                            // TODO: implement
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    ScrollView {
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "info")
                                .frame(width: Styles.charIconSize, height: Styles.charIconSize)
                                .font(.body)
                            
                            Text(company.description)
                        }
                    }
                    .lineLimit(8)
                }
            }
            .opacity(hidden ? 0 : 1)
            .padding()
        }
    }
}
//
//#Preview {
//    CompanyDetails(company: .init(MockData.companies[0]), height: 500.0, checked: false, markAsVisited: {}, uncheck: {})
//}
