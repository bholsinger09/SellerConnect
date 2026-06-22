import Foundation

public struct UserDTO: Codable {
    public let id: UUID
    public let firstName: String
    public let email: String
    
    public init(id: UUID, firstName: String, email: String) {
        self.id = id
        self.firstName = firstName
        self.email = email
    }
}
