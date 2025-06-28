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
    let checked: Bool
    let markAsVisited: () -> Void
    let uncheck: () -> Void
    
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
                                    .frame(width: Styles.charIconSize, height: Styles.charIconSize)
                            case .failure:
                                EmptyView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    // Name
                    Text(company.name)
                    
                    
                    Spacer()
                    
                    // Check/Uncheck button
                    if checked {
                        Button("Uncheck") {
                            uncheck()
                        }
                    } else {
                        Button("Mark as Visited") {
                            markAsVisited()
                        }
                    }
                    
                    // Close Button
                    Button {
                        onClose()
                    } label: {
                        CloseIcon()
                    }
                }
                
                HStack {
                    Image(systemName: "mappin")
                        .frame(width: Styles.charIconSize, height: Styles.charIconSize)
                    Text(company.address)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                HStack {
                    Image(systemName: "figure.walk")
                        .frame(width: Styles.charIconSize, height: Styles.charIconSize)
                    Text("5 min walk")
                    Button("Get Directions") {
                        
                    }
                    Button("Open in Maps") {
                        
                    }
                }
                HStack {
                    ScrollView {
                        Text(Image(systemName: "info")) + Text(company.description)
                    }
                    .lineLimit(8)
                }
            }
            .padding()
        }
        .background {
            RoundedRectangle(cornerRadius: Styles.cornerRadius)
                .fill(Color.whiteOrBlack)
        }
    }
}

#Preview {
    CompanyDetails(company: MockData.companies[0], onClose: {}, checked: false, markAsVisited: {}, uncheck: {})
}
