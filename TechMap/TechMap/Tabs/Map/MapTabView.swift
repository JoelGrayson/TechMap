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
    @State private var route: MKRoute?
    @State private var showingDirections = false
    
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
                    
                    if let route = route {
                        MapPolyline(route)
                            .stroke(.blue, lineWidth: 5)
                    }
                }
                .mapControls {
                    MapUserLocationButton() //center at user's location
                    MapCompass() //only appears when not North
                    MapPitchToggle() //3D/2D button
                    MapScaleView() //only appears when zooming in and out
                }
                .overlay(alignment: .topTrailing) {
                    if showingDirections {
                        Button("Clear Route") {
                            route = nil
                            showingDirections = false
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                }
                
                let height = geo.size.height * 0.5 //height for this company details pane
                
                CompanyDetails(
                    company: $selectedCompany, 
                    checks: checks, 
                    firebaseVM: firebaseVM, 
                    closable: true,
                    onDirectionsRequested: { company in
                        calculateRoute(to: company)
                    }
                )
                .frame(height: height)
                .background {
                    RoundedRectangle(cornerRadius: Styles.cornerRadius)
                        .fill(Color.whiteOrBlack)
                }
                .offset(y: selectedCompany == nil ? height * 1.2 : 0) //when there is no company, it closes itself
                .animation(.spring, value: selectedCompany == nil)
                .padding()
            }
        }
    }
    
    private func calculateRoute(to company: Company) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: company.lat, longitude: company.lng)))
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {
                print("No route found: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.route = route
                self.showingDirections = true
            }
        }
    }
}

#Preview {
    MapTabView(firebaseVM: MockData.firebaseVM, companies: MockData.companies, checks: MockData.checks)
}

