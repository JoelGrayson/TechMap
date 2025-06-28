//
//  InlineLogo.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import SwiftUI

struct InlineLogo: View {
    let imageName: String
    
    var body: some View {
        if let url = imageURL(imageName: imageName) {
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
    }
}

#Preview {
    InlineLogo(imageName: "apple.com.jpg")
}

