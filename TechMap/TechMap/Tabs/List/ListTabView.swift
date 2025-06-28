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
    
    // Computed properties
    var checksWithAssociatedCompanies: [CheckWithAssociatedCompany] {
        checks
            .map { check in
                CheckWithAssociatedCompany(
                    check: check,
                    company: companies.first(where: { company in
                        company.id == check.companyId
                    })
                )
            }
            .sorted {
                $0.check.createdAt > $1.check.createdAt
            }
    }
    var notVisitedYet: [Company] {
        companies.filter {
            !companyChecked(company: $0, checks: checks)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Visited (\(checks.count))")
                    .sectionTitle()
                
                List(checksWithAssociatedCompanies, id: \CheckWithAssociatedCompany.check.id) { c in
                    if let company = c.company {
                        NavigationLink(value: company) {
                            HStack {
                                InlineLogo(imageName: company.imageName)
                                Text(company.name)
                                Spacer()
                                Text(JDateFormatter.formatRelatively(c.check.createdAt))
                                    .padding(.vertical, 4)
                            }
                        }
                    } else {
                        // there is a bug
                        Text(c.check.companyId)
                    }
                }
            }
            .navigationDestination(for: Company.self) { company in
                CompanyDetails(company: .constant(company), checks: checks, firebaseVM: firebaseVM, closable: false)
            }
            .listStyle(.plain)
            
            
            Text("Not Visited Yet (\(notVisitedYet.count))")
                .sectionTitle()
            
            List(notVisitedYet) { company in
                NavigationLink(value: company) {
                    HStack {
                        InlineLogo(imageName: company.imageName)
                        Text(company.name)
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}


struct CheckWithAssociatedCompany {
    let check: Check
    let company: Company?
}

#Preview {
    ListTabView(firebaseVM: MockData.firebaseVM, companies: MockData.companies, checks: MockData.checks)
}
