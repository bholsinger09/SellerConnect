//
//  RegisterViewModel.swift
//  SellerConnect
//
//  Created by Ben H on 6/1/26.
//

import Foundation

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
    
    private let apiBaseURL = "http://192.168.0.47:8080"
    
    var passwordValid: Bool {
        let lengthCheck = password.count >= 6
        let uppercaseCheck = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let digitCheck = password.range(of: "[0-9]", options: .regularExpression) != nil
        let specialCheck = password.range(of: "[\\W&&[^_-]]", options: .regularExpression) != nil
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
        guard let url = URL(string: "\(apiBaseURL)/users") else {
            errorMessage = "Invalid backend URL."
            return
        }
        
        let payload: [String: String] = [
            "firstName": firstName,
            "email": email,
            "password": password
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: payload) else {
            errorMessage = "Failed to encode data."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        isRegistering = true
        errorMessage = ""
        defer { isRegistering = false }
        
        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response from server."
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                registrationSuccess = true
            case 409:
                errorMessage = "Email already registered."
            case 400:
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: responseData),
                   let reason = errorResponse["reason"] {
                    errorMessage = reason
                } else {
                    errorMessage = "Invalid registration data."
                }
            default:
                errorMessage = "Registration failed. Please try again."
            }
        } catch {
            errorMessage = "Network error: \(error.localizedDescription)"
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
