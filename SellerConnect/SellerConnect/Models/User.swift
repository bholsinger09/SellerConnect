import Foundation

struct User: Codable, Sendable {
    let id: UUID
    let firstName: String
    let email: String
    let passwordHash: String
    
    func toDTO() -> UserDTO {
        UserDTO(id: id, firstName: firstName, email: email)
    }
}
