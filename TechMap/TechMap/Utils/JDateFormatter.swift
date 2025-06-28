//
//  JDateFormatter.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import Foundation

struct JDateFormatter {
    static var relativeFormatter: RelativeDateTimeFormatter {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }
    
    static var absoluteFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }
    
    static func formatRelatively(_ date: Date) -> String {
        return self.relativeFormatter.localizedString(for: date, relativeTo: Date())
    }
    
    static func formatAbsolutely(_ date: Date) -> String {
        return self.absoluteFormatter.string(from: date)
    }
}

