//
//  exportToCSV.swift
//  TechMap
//
//  Created by Joel Grayson on 7/7/25.
//

import Foundation

func exportToCSV(_ checksWithCompanies: [CheckWithAssociatedCompany]) -> URL? {
    let header = "visited_at,company_name,address,region,isHeadquarters,company_id\n"
    
    let rows = checksWithCompanies
        .sorted(by: { $0.check.createdAt < $1.check.createdAt })
        .map {
            "\"\($0.check.createdAt)\",\"\($0.company.name)\",\"\($0.company.address)\",\($0.company.region),\($0.company.isHeadquarters ? "TRUE" : "FALSE"),\($0.company.id ?? "NULL")"
        }
    
    let csvString = header + rows.joined(separator: "\n")
    
    let fileName = "Visited_Companies.csv"
    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    do {
        try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    } catch {
        print("Failed to write to CSV: \(error)")
        return nil
    }
}

