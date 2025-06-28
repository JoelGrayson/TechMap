//
//  CloseIcon.swift
//  LockIn
//
//  Created by Joel Grayson on 6/11/25.
//

import SwiftUI

struct CloseIcon: View {
    var body: some View {
        Image(systemName: "xmark")
            .bold()
            .foregroundStyle(.blackOrWhite)
            .padding(Styles.closeIconSize)
            .background {
                Circle()
                    .fill(.red)
            }
    }
}

#Preview {
    CloseIcon()
}
