//
//  View+TextModifiers.swift
//  LockIn
//
//  Created by Joel Grayson on 6/3/25.
//

import SwiftUI

extension View {
    func title() -> some View {
        self
            .font(.title)
            .bold()
    }
    
    func largeTitle() -> some View {
        self
            .font(.largeTitle)
            .bold()
    }
}

