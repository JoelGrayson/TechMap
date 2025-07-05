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
    var markerSize: Settings.MarkerSize
    var isHeadquarters: Bool
    
    // Computed properties
    var scaleFactor: CGFloat {
        selected ? 1.3 : 1.0
    }
    var markerSizeScalingFactor: CGFloat {
        switch markerSize {
        case .small:
            0.75
        case .normal:
            1
        case .large:
            1.25
        }
    }
    
    var body: some View {
        ZStack {
            if isHeadquarters {
                RoundedRectangle(cornerRadius: Styles.cornerRadius)
                    .fill(checked ? Color("Checked") : Color("Unchecked"))
            } else {
                RoundedRectangle(cornerRadius: Styles.cornerRadius)
                    .stroke(checked ? Color("Checked") : Color("Unchecked"), style: StrokeStyle(lineWidth: Styles.borderSize, dash: [5, 3]))
            }
            
            imageIcon
                .padding(
                    isHeadquarters
                    ? Styles.borderSize  //so that there is room for the RoundedRectangle border beneath to show
                    : 0.5 //not necessary since there is a stroked rectangle
                )
            
            if checked {
                CheckmarkShape()
                    .stroke(Color.checked, style: StrokeStyle(lineWidth: Styles.checkmarkSize, lineCap: .round))
                    //.padding([.bottom, .leading], Styles.markerSize*0.2)
                    .offset(x: Styles.markerSize*0.2, y: Styles.markerSize*(-0.1))
            }
        }
        .frame(
            width: Styles.markerSize * markerSizeScalingFactor * scaleFactor,
            height: Styles.markerSize * markerSizeScalingFactor * scaleFactor
        )
        .animation(.spring(duration: Styles.animationDuration), value: scaleFactor)
    }
    
    var imageIcon: some View {
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
        JMarker(checked: true, imageName: "apple.com.jpg", selected: false, markerSize: .normal, isHeadquarters: true)
        JMarker(checked: false, imageName: "apple.com.jpg", selected: false, markerSize: .normal, isHeadquarters: false)
    }
}

