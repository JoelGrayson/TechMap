//
//  CompanyDetails.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import SwiftUI

struct CompanyDetails: View {
    let company: Company
    let onClose: () -> Void
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    if let url = imageURL(imageName: company.imageName) {
                        AsyncImage(url: url)
                    }
                    Text(company.name)
                    //TODO: (5 min walk)
                }
                
                Text(company.address)
                Text(company.description)
            }
            .padding()
        }
        .background {
            RoundedRectangle(cornerRadius: Styles.cornerRadius)
                .fill(Color.whiteOrBlack)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                onClose()
            } label: {
                CloseIcon()
            }
        }
    }
}

#Preview {
    CompanyDetails(company: MockData.companies[0], onClose: {})
}
