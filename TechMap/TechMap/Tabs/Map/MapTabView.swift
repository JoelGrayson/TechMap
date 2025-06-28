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
    
    @State var selectedCompany: Company?
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Map(selection: $selectedCompany) {
                    UserAnnotation() //display user's current location on the map
                    
                    ForEach(companies) { company in
                        Annotation(company.name, coordinate: .init(latitude: company.lat, longitude: company.lng)) {
                            JMarker(
                                checked: company.name.first == "A",
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
                
                if let selectedCompany {
                    CompanyDetails(
                        company: selectedCompany,
                        onClose: {
                            self.selectedCompany = nil
                        },
                        // TODO: fill in these values
                        checked: false,
                        markAsVisited: {
                            
                        },
                        uncheck: {
                            
                        }
                    )
                    .frame(width: geo.size.width, height: geo.size.height * 0.4)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    MapTabView(firebaseVM: MockData.firebaseVM, companies: MockData.companies)
}
