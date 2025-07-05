//
//  Company.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import SwiftUI
import FirebaseFirestore

struct Company: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name: String
    var address: String
    var lat: Double
    var lng: Double
    var imageName: String
    var description: String
    var wikipediaSlug: String
    var region: String
    var isHeadquarters: Bool
}

