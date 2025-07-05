//
//  FeedbackButton.swift
//  TechMap
//
//  Created by Joel Grayson on 6/30/25.
//

import SwiftUI

struct FeedbackButton: View {
    var body: some View {
        if let url = URL(string: "https://forms.gle/WvifgC66xR2g1Y5p6") {
            Link(destination: url) {
                Text("Give Feedback") //Report a Bug
            }
            .buttonStyle(.bordered)
        } else {
            Text("If you have any feedback or there is a bug, feel free to email joel@joelgrayson.com")
        }
    }
}

#Preview {
    FeedbackButton()
}

