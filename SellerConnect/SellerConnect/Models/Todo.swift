import Foundation

struct Todo: Codable, Sendable {
    let id: UUID
    let title: String
    
    func toDTO() -> TodoDTO {
        TodoDTO(id: id, title: title)
    }
}
