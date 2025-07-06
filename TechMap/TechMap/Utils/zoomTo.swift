//
//  zoomTo.swift
//  TechMap
//
//  Created by Joel Grayson on 7/5/25.
//

import SwiftUI
import MapKit
import CoreLocation

func zoomTo(coordinate: CLLocationCoordinate2D) -> MapCameraPosition {
    let region = MKCoordinateRegion(
        center: coordinate,
        latitudinalMeters: 8047, // 5 miles in meters
        longitudinalMeters: 8047
    )
    return .region(region)
}

