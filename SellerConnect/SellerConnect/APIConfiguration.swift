//
//  APIConfiguration.swift
//  SellerConnect
//
//  Created by Ben H on 6/1/26.
//

import Foundation

struct APIConfiguration {
    enum Environment {
        case embedded
        case development
        case staging
        case production
        
        var baseURL: String {
            switch self {
            case .embedded:
                return "http://localhost:8080"
            case .development:
                return "http://localhost:8080"
            case .staging:
                return "https://staging-api.sellerconnect.app"
            case .production:
                return "https://api.sellerconnect.app"
            }
        }
    }
    
    static let current: Environment = {
        #if DEBUG
        return .embedded
        #else
        return .production
        #endif
    }()
    
    static let baseURL = current.baseURL
}
