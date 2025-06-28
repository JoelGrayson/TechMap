//
//  MapTabView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI
import MapKit
import Kingfisher

struct MapTabView: View {
    var firebaseVM: FirebaseVM
    var companies: [Company]
    var checks: [Check]
    
    @State var selectedCompany: Company?
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Map(selection: $selectedCompany) {
                    UserAnnotation() //display user's current location on the map
                    
                    ForEach(companies) { company in
                        Annotation(company.name, coordinate: .init(latitude: company.lat, longitude: company.lng)) {
                            JMarker(
                                checked: companyChecked(company: company, checks: checks),
                                imageName: company.imageName,
                                selected: selectedCompany == company
                            )
                        }
                        .tag(company)
                    }
                }
                .mapControls {
                    MapUserLocationButton() //center at user's location
                    MapCompass() //only appears when not North
                    MapPitchToggle() //3D/2D button
                    MapScaleView() //only appears when zooming in and out
                }
                
                let companyDetailsHeight = geo.size.height * 0.5
                
                CompanyDetails(
                    company: $selectedCompany,
                    height: companyDetailsHeight,
                    
                    checked: companyChecked(company: selectedCompany, checks: checks),
                    markAsVisited: {
                        firebaseVM.addCheck(companyId: selectedCompany?.id)
                    },
                    uncheck: {
                        firebaseVM.deleteCheck(companyId: selectedCompany?.id)
                    }
                )
                .frame(height: companyDetailsHeight)
                .padding()
            }
        }
    }
}

#Preview {
    MapTabView(firebaseVM: MockData.firebaseVM, companies: MockData.companies, checks: MockData.checks)
}

