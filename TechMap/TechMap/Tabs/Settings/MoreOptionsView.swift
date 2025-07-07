//
//  MoreOptionsView.swift
//  TechMap
//
//  Created by Joel Grayson on 7/7/25.
//

import SwiftUI

struct MoreOptionsView: View {
    var firebaseVM: FirebaseVM
    
    @State private var showDeleteAlert = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Styles.settingsGapBetweenItems) {
            Text("Manage Account")
                .sectionTitle()
            
            Button("Delete Account", role: .destructive) {
                showDeleteAlert = true
            }
            .buttonStyle(.bordered)
            .alert("Are you sure you want to delete your account? This deletes your data as well and is irreversible.", isPresented: $showDeleteAlert) {
                Button("Yes, delete", role: .destructive) {
                    Task {
                        await deleteAccount()
                    }
                }
                Button("Nevermind", role: .cancel) { }
            }
            
            if let errorMessage = errorMessage {
                Text("Error deleting account: \(errorMessage)")
            }
            
            Spacer()
        }
    }
    
    private func deleteAccount() async {
        do {
            try await firebaseVM.deleteAccount()
        } catch {
            if let deleteError = error as? FirebaseVM.DeleteAccountError {
                switch deleteError {
                case .noCurrentUser:
                    errorMessage = "There is no current user to delete"
                case .failedToDeleteCheckmarks:
                    errorMessage = "Could not delete the user's checkmarks"
                case .failedToDeleteUser:
                    errorMessage = "Could not delete the user"
                }
            }
        }
    }
}

