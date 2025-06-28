//
//  UserWrapper.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import SwiftUI

struct UserWrapper: View {
    @State private var firebaseVM = FirebaseVM()
    
    var body: some View {
        TabsView()
    }
}

#Preview {
    UserWrapper()
}
