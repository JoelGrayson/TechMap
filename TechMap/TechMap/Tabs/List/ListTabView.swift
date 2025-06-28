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
    
    var body: some View {
        Text("Visited \(checks.count) of \(companies.count) companies")
        
        Text("Visited")
            .bold()
        
        List(checks) { check in
            Text(check.companyId)
        }
        
        Text("Not Visited Yet")
            .bold()
        
    }
}

#Preview {
    ListTabView(firebaseVM: MockData.firebaseVM, companies: MockData.companies, checks: MockData.checks)
}
