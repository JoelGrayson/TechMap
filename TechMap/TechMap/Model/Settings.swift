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
    var region: Region? //which region to show in the ListTabView. Stored in settings so it is persisted.
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
    
    enum Region: String, Codable {
        case nyc = "NYC"
        case bayArea = "Bay Area"
        case seattle = "Seattle Metropolitan Area"
        case all = "All"
        
        var code: String { // region.code used in firebase. region.rawValue is used for displaying
            switch self {
            case .nyc: "nyc"
            case .bayArea: "bay-area"
            case .seattle: "seattle"
            case .all: "all"
            }
        }
        var fullDescription: String {
            switch self {
            case .nyc: "NYC"
            case .bayArea: "the Bay Area"
            case .seattle: "the Seattle Metropolitan Area"
            case .all: "All"
            }
        }
    }
    
    static let defaultSettings = Settings()
}

