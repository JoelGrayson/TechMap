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
                    // Logo
                    if let url = imageURL(imageName: company.imageName) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .frame(width: Styles.charSize, height: Styles.charSize)
                            case .failure:
                                EmptyView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    // Name
                    Text(company.name)
                    
                    
                    
                }
                
                HStack {
                    Image(systemName: "mappin")
                    Text(company.address)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                HStack {
                    Text("5 min walk")
                    Button("Get Directions") {
                        
                    }
                    Button("Open in Maps") {
                        
                    }
                }
                HStack {
                    ScrollView {
                        Text(company.description)
                    }
                }
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
            .padding([.trailing, .top])
        }
    }
}

#Preview {
    CompanyDetails(company: MockData.companies[0], onClose: {})
}
