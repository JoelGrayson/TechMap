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
    var settings: Settings?
    func startTracking() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    // Calculated published properties. Accessed by the user
    var time: String?
    var rawTimeInterval: TimeInterval?
    var distance: String?
    var currentLocation: CLLocation?
    var heading: CLLocationDirection = 0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Internal stuff to make sure it works
    private var locationManager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last //useful for the map centering at the start
        calculate() //when moving around, calculate the new location
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.trueHeading
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
        request.transportType = jTransportationTypeToMK((settings ?? Settings.defaultSettings).transportationMethod)
        
        let directions = MKDirections(request: request)
        directions.calculateETA { response, error in
            DispatchQueue.main.async {
                if let response = response {
                    // Format distance using MeasurementFormatter
                    let distanceFormatter = MeasurementFormatter()
                    distanceFormatter.unitOptions = .naturalScale
                    distanceFormatter.numberFormatter.maximumFractionDigits = 1
                    let distance = Measurement(value: response.distance, unit: UnitLength.meters)
                    self.distance = distanceFormatter.string(from: distance)
                    
                    // Format time using DateComponentsFormatter
                    let timeFormatter = DateComponentsFormatter()
                    timeFormatter.unitsStyle = .abbreviated
                    timeFormatter.allowedUnits = [.hour, .minute]
                    self.time = timeFormatter.string(from: response.expectedTravelTime)
                    self.rawTimeInterval = response.expectedTravelTime
                }
            }
        }
    }
}

