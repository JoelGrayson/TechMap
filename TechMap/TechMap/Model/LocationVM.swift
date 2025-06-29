//
//  LocationVM.swift
//  TechMap
//
//  Created by Joel Grayson on 6/29/25.
//

import Foundation
import CoreLocation
import MapKit

// Used to track the user's location and how far (in meters/feet and time) they are from a company
@Observable //publishes the distance and time dynamic variables
class LocationVM: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    private(set) var company: Company? //set by the user in startTracking()
    
    // Published dynamic information
    var userLocation: CLLocation?
    var distance: String? //e.g., "30 ft"
    var time: String? //e.g., "5 min"
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        calculate()
    }
    
    // Methods the user should use to change the self.company
    func startTracking(company: Company) {
        self.company = company
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        self.company = nil
        locationManager.stopUpdatingLocation()
    }
    
    // Delegate methods the locationManager uses
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        calculate()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("JLocationManager error: \(error.localizedDescription)")
    }
    
    func calculate() {
        guard let company, userLocation != nil else {
            print("Could not calculate because company or userLocation is undefined")
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: company.lat, longitude: company.lng)))
        request.transportType = .walking //TODO: make this configurable in settings
        let directions = MKDirections(request: request)
        directions.calculateETA { response, error in
            DispatchQueue.main.async {
                if let response {
                    self.time = response.expectedTravelTime.description
                    self.distance = response.distance.description
                }
            }
        }
    }
}

