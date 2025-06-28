//
//  JMarker.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import SwiftUI

struct JMarker: View {
    var checked: Bool
    var imageName: String
    var selected: Bool
    
    // Computed properties
    var scaleFactor: CGFloat {
        selected ? 1.3 : 1.0
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Styles.cornerRadius)
                .fill(checked ? Color("Checked") : Color("Unchecked"))
            
            AsyncImage(url: imageURL(imageName: imageName)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: Styles.cornerRadius))
                case .failure(_): //let error
                    EmptyView()
                @unknown default:
                    EmptyView()
                }
            }
            .padding(Styles.borderSize) //so that there is room for the RoundedRectangle border beneath to show
            
            if checked {
                CheckmarkShape()
                    .stroke(Color.checked, style: StrokeStyle(lineWidth: Styles.checkmarkSize, lineCap: .round))
                    //.padding([.bottom, .leading], Styles.markerSize*0.2)
                    .offset(x: Styles.markerSize*0.2, y: Styles.markerSize*(-0.1))
            }
        }
        .frame(
            width: Styles.markerSize * scaleFactor,
            height: Styles.markerSize * scaleFactor
        )
        .animation(.spring(duration: Styles.animationDuration), value: scaleFactor)
    }
}

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX+0.03*rect.width, y: rect.minY+0.45*rect.height))
        path.addLine(to: CGPoint(x: rect.minX+0.3*rect.width, y: rect.minY+0.75*rect.height))
        path.addLine(to: CGPoint(x: rect.minX+rect.width*0.8, y: rect.minY+0.15*rect.height))
        return path
    }
}

#Preview {
    VStack {
        JMarker(checked: true, imageName: "apple.com.jpg", selected: false)
        JMarker(checked: false, imageName: "apple.com.jpg", selected: false)
    }
}
