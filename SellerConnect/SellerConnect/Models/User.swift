//
//  User.swift
//  SellerConnect
//
//  Created by Ben H on 6/1/26.
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID?
    let firstName: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case email
    }
}
