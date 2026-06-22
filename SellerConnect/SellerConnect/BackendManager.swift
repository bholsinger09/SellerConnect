//
//  BackendManager.swift
//  SellerConnect
//
//  This file bridges the app to the embedded backend services.
//

import Foundation

@MainActor
class BackendManager {
    static let shared = BackendManager()
    
    func registerUser(firstName: String, email: String, password: String) async throws -> UserDTO {
        return try await UserService.shared.register(firstName: firstName, email: email, password: password)
    }
    
    func authenticateUser(email: String, password: String) async throws -> UserDTO {
        return try await UserService.shared.authenticate(email: email, password: password)
    }
}
