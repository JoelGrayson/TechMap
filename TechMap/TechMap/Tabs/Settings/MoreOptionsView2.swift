//
//  MoreOptionsView.swift
//  TechMap
//
//  Created by Joel Grayson on 6/26/25.
//

import SwiftUI

struct MoreOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAccountAlert = false
    @State private var isDeleting = false
    @State private var deleteAccountError: String?
    
    var firebaseVM: FirebaseVM
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("More Options")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                VStack(spacing: 16) {
                    // Account Deletion Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Account Management")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Delete your account and all associated data permanently.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        showingDeleteAccountAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Account")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                    .disabled(isDeleting)
                    
                    if let error = deleteAccountError {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await deleteAccount()
                }
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone and will permanently delete all your data including your visited companies list.")
        }
        .overlay {
            if isDeleting {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Deleting account...")
                        .padding(.top)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }
        }
    }
    
    private func deleteAccount() async {
        isDeleting = true
        deleteAccountError = nil
        
        do {
            await firebaseVM.deleteAccount()
            dismiss()
        } catch {
            deleteAccountError = error.localizedDescription
        }
        
        isDeleting = false
    }
}

#Preview {
    MoreOptionsView(firebaseVM: FirebaseVM())
}