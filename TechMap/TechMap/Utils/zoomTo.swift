//
//  zoomTo.swift
//  TechMap
//
//  Created by Joel Grayson on 7/5/25.
//

import SwiftUI
import MapKit
import CoreLocation

func zoomTo(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) -> MapCameraPosition {
    let region = MKCoordinateRegion(
        center: coordinate,
        latitudinalMeters: radius,
        longitudinalMeters: radius
    )
    return .region(region)
}

