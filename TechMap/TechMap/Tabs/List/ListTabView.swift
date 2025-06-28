//
//  ListTabView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI

struct ListTabView: View {
    var firebaseVM: FirebaseVM
    var companies: [Company]
    var checks: [Check]
    
        var notVisitedYet: [Company] {
            companies.filter {
                !companyChecked(company: $0, checks: checks)
            }
        }

    var body: some View {
        Text("Visited \(checks.count) of \(companies.count) companies")
        
        Text("Visited")
            .sectionTitle()
        
        List(checks) { check in
            let associatedCompany = companies.first(where: { $0.id == check.companyId })
            if let associatedCompany {
                HStack {
                    InlineLogo(imageName: associatedCompany.imageName)
                    Text(associatedCompany.name)
                    Spacer()
                    Text(RelativeDateFormatter.format(check.createdAt))
                }
            } else {
                // there is a bug
                Text(check.companyId)
            }
        }
        
        Text("Not Visited Yet")
            .sectionTitle()
        
        List(notVisitedYet) { company in
            HStack {
                InlineLogo(imageName: company.imageName)
                Text(company.name)
            }
        }
    }
}

#Preview {
    ListTabView(firebaseVM: MockData.firebaseVM, companies: MockData.companies, checks: MockData.checks)
}
