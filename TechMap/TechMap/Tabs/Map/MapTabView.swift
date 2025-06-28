//
//  MapTabView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI

struct MapTabView: View {
    var firebaseVM: FirebaseVM
    var companies: [Company]
    
    var body: some View {
        Text("Hello, World!")
        List(companies) { company in
            Text(company.name)
        }
    }
}

#Preview {
    MapTabView(firebaseVM: MockData.firebaseVM, companies: MockData.companies)
}
