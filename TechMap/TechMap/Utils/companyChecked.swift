//
//  companyChecked.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import Foundation

func companyChecked(company: Company?, checks: [Check]) -> Bool {
    return checks.contains(where: { $0.companyId == company?.id })
}

func associatedCheck(company: Company?, checks: [Check]) -> Check? {
    return checks.first(where: { $0.companyId == company?.id })
}

