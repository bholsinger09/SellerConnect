import Foundation
import CryptoKit

public struct RegistrationError: Error, Equatable {
    public let message: String
    
    public init(_ message: String) {
        self.message = message
    }
}

public actor UserService {
    public static let shared = UserService()
    
    private var users: [String: StoredUser] = [:]
    
    nonisolated private init() {
        // Initialize empty, loadUsers will be called on first use
    }
    
    public func register(firstName: String, email: String, password: String) async throws -> UserDTO {
        // Load users on first access
        if users.isEmpty {
            loadUsers()
        }
        
        // Validate inputs
        try validatePassword(password)
        try validateEmail(email)
        
        // Check if email already exists
        if users[email] != nil {
            throw RegistrationError("Email already registered")
        }
        
        // Hash password
        let hash = hashPassword(password)
        
        // Create user
        let id = UUID()
        let user = StoredUser(id: id, firstName: firstName, email: email, passwordHash: hash)
        users[email] = user
        
        // Persist
        saveUsers()
        
        return UserDTO(id: id, firstName: firstName, email: email)
    }
    
    public func authenticate(email: String, password: String) async throws -> UserDTO {
        guard let user = users[email] else {
            throw RegistrationError("User not found")
        }
        
        if !verifyPassword(password, against: user.passwordHash) {
            throw RegistrationError("Invalid password")
        }
        
        return UserDTO(id: user.id, firstName: user.firstName, email: user.email)
    }
    
    private func validatePassword(_ password: String) throws {
        if password.count < 6 {
            throw RegistrationError("Password must be at least 6 characters")
        }
        
        if !password.contains(where: { $0.isUppercase }) {
            throw RegistrationError("Password must contain at least one uppercase letter")
        }
        
        if !password.contains(where: { $0.isNumber }) {
            throw RegistrationError("Password must contain at least one number")
        }
        
        let specialCharPattern = "[^a-zA-Z0-9_-]"
        let regex = try NSRegularExpression(pattern: specialCharPattern)
        let range = NSRange(password.startIndex..<password.endIndex, in: password)
        if regex.firstMatch(in: password, range: range) == nil {
            throw RegistrationError("Password must contain at least one special character")
        }
    }
    
    private func validateEmail(_ email: String) throws {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let regex = try NSRegularExpression(pattern: emailPattern)
        let range = NSRange(email.startIndex..<email.endIndex, in: email)
        if regex.firstMatch(in: email, range: range) == nil {
            throw RegistrationError("Invalid email format")
        }
    }
    
    private func hashPassword(_ password: String) -> String {
        let data = password.data(using: .utf8) ?? Data()
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    private func verifyPassword(_ password: String, against hash: String) -> Bool {
        hashPassword(password) == hash
    }
    
    private func saveUsers() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(Array(users.values)),
           let json = String(data: data, encoding: .utf8) {
            UserDefaults.standard.set(json, forKey: "users")
        }
    }
    
    private func loadUsers() {
        if let json = UserDefaults.standard.string(forKey: "users"),
           let data = json.data(using: .utf8) {
            let decoder = JSONDecoder()
            if let storedUsers = try? decoder.decode([StoredUser].self, from: data) {
                users = Dictionary(uniqueKeysWithValues: storedUsers.map { ($0.email, $0) })
            }
        }
    }
}

private struct StoredUser: Codable {
    let id: UUID
    let firstName: String
    let email: String
    let passwordHash: String
}
