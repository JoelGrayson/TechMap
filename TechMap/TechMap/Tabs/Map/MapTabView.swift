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
        Text("Hello, World!")
//        List(companies) { company in
//            Text(company.name)
//        }
        Map(selection: $selectedCompany) {
            UserAnnotation() //display user's current location on the map
            
            ForEach(companies) { company in
                Annotation(company.name, coordinate: .init(latitude: company.lat, longitude: company.lng)) {
                    VStack {
                        if let url = URL(string: Constants.imageBasePath+company.imageName) {
                            KFImage(url)
                        }
                    }
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
    }
}

#Preview {
    MapTabView(firebaseVM: MockData.firebaseVM, companies: MockData.companies)
}
