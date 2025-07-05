//
//  RatingButton.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//


// Created by Claude Code

import SwiftUI
import StoreKit

struct RatingButton: View {
    @Environment(\.requestReview) private var requestReview
    
    var body: some View {
        Button("Leaving a Rating") {
            requestReview()
        }
        .buttonStyle(.bordered)
    }
}
