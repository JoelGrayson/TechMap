//
//  MapTabView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI
import MapKit
import Kingfisher
import SwiftData

struct MapTabView: View {
    var firebaseVM: FirebaseVM
    var locationVM: LocationVM
    var companies: [Company]
    var checks: [Check]
    
    @State var selectedCompany: Company?
    @State private var route: MKRoute?
    @State private var showingDirections = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    @Query var rawSettings: [Settings]
    var settings: Settings {
        rawSettings.first ?? Settings.defaultSettings
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition, selection: $selectedCompany) {
                    UserAnnotation {
                        ZStack {
                            // Direction cone/sector with gradient
                            Path { path in
                                let center = CGPoint(x: 25.5, y: 25.5)
                                let radius: CGFloat = 44.6
                                let startAngle: Double = -30 // degrees
                                let endAngle: Double = 30   // degrees
                                
                                path.move(to: center)
                                path.addArc(center: center, 
                                           radius: radius, 
                                           startAngle: .degrees(startAngle), 
                                           endAngle: .degrees(endAngle), 
                                           clockwise: false)
                                path.closeSubpath()
                            }
                            .fill(
                                RadialGradient(
                                    colors: [.blue.opacity(0.6), .blue.opacity(0.1)],
                                    center: .center,
                                    startRadius: 12.8,
                                    endRadius: 44.6
                                )
                            )
                            .frame(width: 51, height: 51)
                            
                            // Main blue dot
                            Circle()
                                .fill(.blue)
                                .frame(width: 20.4, height: 20.4)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: 2.6)
                                )
                        }
                        .rotationEffect(Angle(degrees: locationVM.heading))
                    }
                    
                    ForEach(companies) { company in
                        Annotation(company.name, coordinate: .init(latitude: company.lat, longitude: company.lng)) {
                            JMarker(
                                checked: companyChecked(company: company, checks: checks),
                                imageName: company.imageName,
                                selected: selectedCompany == company,
                                markerSize: settings.markerSize
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
                .onAppear {
                    setInitialMapRegion()
                }
                .onChange(of: locationVM.currentLocation) {
                    if cameraPosition == .automatic {
                        setInitialMapRegion()
                    }
                }
                .overlay(alignment: .topLeading) {
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
                    locationVM: locationVM,
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
    
    private func setInitialMapRegion() {
        if let userLocation = locationVM.currentLocation {
            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                latitudinalMeters: 8047, // 5 miles in meters
                longitudinalMeters: 8047
            )
            cameraPosition = .region(region)
        }
    }
    
    private func calculateRoute(to company: Company) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: company.lat, longitude: company.lng)))
        request.transportType = jTransportationTypeToMK(settings.transportationMethod)
        
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
    MapTabView(firebaseVM: MockData.firebaseVM, locationVM: .init(), companies: MockData.companies, checks: MockData.checks)
}

