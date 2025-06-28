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
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Visited (\(checks.count))")
                    .sectionTitle()
                
                List(checks) { check in
                    let associatedCompany = companies.first(where: { $0.id == check.companyId })
                    
                    NavigationLink(value: associatedCompany) {
                        HStack {
                            if let associatedCompany {
                                InlineLogo(imageName: associatedCompany.imageName)
                                Text(associatedCompany.name)
                                Spacer()
                                Text(JDateFormatter.formatRelatively(check.createdAt))
                                    .padding(.vertical, 4)
                            } else {
                                // there is a bug
                                Text(check.companyId)
                            }
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
}

#Preview {
    ListTabView(firebaseVM: MockData.firebaseVM, companies: MockData.companies, checks: MockData.checks)
}
