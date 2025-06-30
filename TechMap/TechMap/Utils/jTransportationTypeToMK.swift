//
//  jTransportationTypeToMK.swift
//  TechMap
//
//  Created by Joel Grayson on 6/30/25.
//

import Foundation
import MapKit

func jTransportationTypeToMK(_ j: Settings.TransportMethod) -> MKDirectionsTransportType {
    switch j {
    case .driving:
        return MKDirectionsTransportType.automobile
    case .walking:
        return MKDirectionsTransportType.walking
    }
}

