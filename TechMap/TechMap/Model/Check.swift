//
//  Check.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import SwiftUI
import FirebaseFirestore

struct Check: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var companyId: String
    var userId: String
    var createdAt: Date
    var device: String
}

