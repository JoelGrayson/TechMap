//
//  RelativeDateFormatter.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import Foundation

struct RelativeDateFormatter {
    static var formatter: RelativeDateTimeFormatter {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        return f
    }
    
    static func format(_ date: Date) -> String {
        return self.formatter.localizedString(for: date, relativeTo: Date())
    }
}

