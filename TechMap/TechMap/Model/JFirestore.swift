//
//  JFirestore.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import FirebaseCore
import FirebaseFirestore

struct JFirestore {
    static let techmapDb = Firestore.firestore(database: "techmap")
}
