//
//  Settings.swift
//  TechMap
//
//  Created by Joel Grayson on 6/29/25.
//

import Foundation
import SwiftData

@Model
class Settings {
    var markerSize: MarkerSize = MarkerSize.normal
    var transportationMethod: TransportMethod = TransportMethod.walking
    var playSoundWhenChecked: Bool = true
    // account/auth managed by FirebaseVM
    
    init(markerSize: MarkerSize = .normal, transportationMethod: TransportMethod = .walking, playSoundWhenChecked: Bool = true) {
        self.markerSize = markerSize
        self.transportationMethod = transportationMethod
        self.playSoundWhenChecked = playSoundWhenChecked
    }
    
    enum TransportMethod: String, Codable {
        case walking //default
        case driving
    }
    
    enum MarkerSize: String, Codable {
        case small
        case normal //default
        case large
    }
    
    static let defaultSettings = Settings()
}

