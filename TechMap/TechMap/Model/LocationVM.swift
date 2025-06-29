//
//  LocationVM.swift
//  TechMap
//
//  Created by Joel Grayson on 6/29/25.
//

import Foundation
import CoreLocation
import MapKit

@Observable
class LocationVM: NSObject, CLLocationManagerDelegate {
    // Called/set by the user
    var company: Company? { //company to reference all the calculations to
        didSet {
            calculate()
        }
    }
    func startTracking() {
        locationManager.startUpdatingLocation()
    }
    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    // Calculated published properties. Accessed by the user
    var time: String?
    var distance: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // Internal stuff to make sure it works
    private var locationManager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        calculate() //when moving around, calculate the new location
    }
    
    func calculate() {
        guard let company else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(
            placemark: MKPlacemark(
                coordinate: CLLocationCoordinate2D(latitude: company.lat, longitude: company.lng)
            )
        )
        request.transportType = .walking //TODO: make this configurable in settings
        
        let directions = MKDirections(request: request)
        directions.calculateETA { response, error in
            DispatchQueue.main.async {
                self.distance = response?.distance.description
                self.time = response?.expectedTravelTime.description
            }
        }
    }
}
