//
//  UserWrapper.swift
//  TechMap
//
//  Created by Joel Grayson on 6/28/25.
//

import SwiftUI
import SwiftData

struct UserWrapper: View {
    @Environment(\.modelContext) var modelContext
    @Query var rawSettings: [Settings]
    
    @State private var firebaseVM = FirebaseVM()
    
    var body: some View {
        VStack {
            if firebaseVM.isSignedIn == .notSignedIn {
                ProgressView() //creating an account for anything to work
            } else {
                TabsView(firebaseVM: firebaseVM)
            }
        }
            .onAppear {
                firebaseVM.checkAuthState()
            }
            .task {
                if rawSettings.isEmpty {
                    modelContext.insert(Settings())
                }
            }
    }
}

#Preview {
    UserWrapper()
}
