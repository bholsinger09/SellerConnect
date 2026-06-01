//
//  RegisterView.swift
//  SellerConnect
//
//  Created by Ben H on 5/30/26.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Register")) {
                TextField("First Name", text: $viewModel.firstName)
                    .autocapitalization(.words)
                    .textContentType(.givenName)
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                Group {
                    if viewModel.showPassword {
                        TextField("Password", text: $viewModel.password)
                    } else {
                        SecureField("Password", text: $viewModel.password)
                    }
                    Button(viewModel.showPassword ? "Hide" : "Show") {
                        viewModel.showPassword.toggle()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
                }
                Group {
                    if viewModel.showConfirmPassword {
                        TextField("Confirm Password", text: $viewModel.confirmPassword)
                    } else {
                        SecureField("Confirm Password", text: $viewModel.confirmPassword)
                    }
                    Button(viewModel.showConfirmPassword ? "Hide" : "Show") {
                        viewModel.showConfirmPassword.toggle()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
                }
            }
            
            Section(header: Text("Password Requirements")) {
                VStack(alignment: .leading, spacing: 4) {
                    RequirementRow(requirement: "At least 6 characters", satisfied: viewModel.password.count >= 6)
                    RequirementRow(requirement: "At least 1 uppercase letter", satisfied: viewModel.password.range(of: "[A-Z]", options: .regularExpression) != nil)
                    RequirementRow(requirement: "At least 1 number", satisfied: viewModel.password.range(of: "[0-9]", options: .regularExpression) != nil)
                    RequirementRow(requirement: "At least 1 special character (no _ or -)", satisfied: viewModel.password.range(of: "[\\W&&[^_-]]", options: .regularExpression) != nil)
                    RequirementRow(requirement: "No underscores or dashes", satisfied: viewModel.password.range(of: "[_-]", options: .regularExpression) == nil)
                }
                .font(.caption)
            }
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundStyle(.red)
            }
            
            if viewModel.registrationSuccess {
                Text("Registration successful!")
                    .foregroundStyle(.green)
            }
            
            Button(viewModel.isRegistering ? "Registering..." : "Register") {
                Task {
                    if !viewModel.passwordValid {
                        viewModel.errorMessage = "Password does not meet requirements."
                    } else if !viewModel.passwordsMatch {
                        viewModel.errorMessage = "Passwords do not match."
                    } else {
                        await viewModel.register()
                    }
                }
            }
            .disabled(!viewModel.canSubmit || viewModel.isRegistering)
        }
        .navigationTitle("Register")
    }
}

struct RequirementRow: View {
    let requirement: String
    let satisfied: Bool
    
    var body: some View {
        HStack {
            Image(systemName: satisfied ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(satisfied ? .green : .secondary)
            Text(requirement)
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
