//
//  RegisterViewModel.swift
//  SellerConnect
//
//  Created by Ben H on 6/1/26.
//

import Foundation
import Combine

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var showPassword = false
    @Published var showConfirmPassword = false
    @Published var errorMessage = ""
    @Published var isRegistering = false
    @Published var registrationSuccess = false
    
    var passwordValid: Bool {
        let lengthCheck = password.count >= 6
        let uppercaseCheck = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let digitCheck = password.range(of: "[0-9]", options: .regularExpression) != nil
        let specialCheck = password.range(of: "[^a-zA-Z0-9_-]", options: .regularExpression) != nil
        let underscoreOrDashCheck = password.range(of: "[_-]", options: .regularExpression) == nil
        return lengthCheck && uppercaseCheck && digitCheck && specialCheck && underscoreOrDashCheck
    }
    
    var passwordsMatch: Bool {
        password == confirmPassword && !password.isEmpty
    }
    
    var canSubmit: Bool {
        !firstName.isEmpty && !email.isEmpty && passwordValid && passwordsMatch
    }
    
    func register() async {
        isRegistering = true
        errorMessage = ""
        defer { isRegistering = false }
        
        let payload: [String: String] = [
            "firstName": firstName,
            "email": email,
            "password": password
        ]
        
        do {
            let _: [String: String] = try await APIClient.shared.post(endpoint: "/users", body: payload)
            registrationSuccess = true
            resetForm()
        } catch let error as APIClient.APIError {
            switch error {
            case .serverError(let statusCode, let message):
                if statusCode == 409 {
                    errorMessage = "Email already registered."
                } else {
                    errorMessage = message
                }
            case .networkError(let networkError):
                errorMessage = "Network error: \(networkError.localizedDescription)"
            default:
                errorMessage = error.errorDescription ?? "Registration failed. Please try again."
            }
        } catch {
            errorMessage = "Registration failed. Please try again."
        }
    }
    
    func resetForm() {
        firstName = ""
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = ""
        registrationSuccess = false
        showPassword = false
        showConfirmPassword = false
    }
}

