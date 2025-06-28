//
//  CompanyDetails.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import SwiftUI

struct CompanyDetails: View {
    @Binding var company: Company?
    let height: CGFloat
    let checked: Bool
    let markAsVisited: () -> Void
    let uncheck: () -> Void
    
    var hidden: Bool {
        company == nil
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    // Logo
                    if let company {
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
                    }
                    
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
                        self.company = nil
                    } label: {
                        CloseIcon()
                    }
                }
                
                HStack {
                    Image(systemName: "mappin")
                        .frame(width: Styles.charIconSize, height: Styles.charIconSize)
                    Text(company?.address ?? "")
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
                        Text(Image(systemName: "info")) + Text(company?.description ?? "")
                    }
                    .lineLimit(8)
                }
            }
            .opacity(hidden ? 0 : 1)
            .padding()
        }
        .background {
            RoundedRectangle(cornerRadius: Styles.cornerRadius)
                .fill(Color.whiteOrBlack)
        }
        .offset(y: hidden ? height * 1.2 : 0) //when there is no company, it closes itself
        .animation(.spring, value: hidden)
    }
}
//
//#Preview {
//    CompanyDetails(company: .init(MockData.companies[0]), height: 500.0, checked: false, markAsVisited: {}, uncheck: {})
//}
