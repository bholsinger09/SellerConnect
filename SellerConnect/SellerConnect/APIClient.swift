//
//  APIClient.swift
//  SellerConnect
//
//  Created by Ben H on 6/1/26.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let baseURL = APIConfiguration.baseURL
    
    enum APIError: LocalizedError {
        case invalidURL
        case invalidResponse
        case decodingError
        case serverError(statusCode: Int, message: String)
        case networkError(Error)
        case connectionRefused
        case timeoutError
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid response from server"
            case .decodingError:
                return "Failed to decode response"
            case .serverError(_, let message):
                return message
            case .networkError(let error):
                return error.localizedDescription
            case .connectionRefused:
                return "Cannot connect to the server. Is the backend running on localhost:8080?"
            case .timeoutError:
                return "Connection timed out. Please check your network and try again."
            }
        }
    }
    
    func post<T: Decodable>(endpoint: String, body: [String: String]) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
            throw APIError.decodingError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        request.timeoutInterval = 10.0
        
        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: responseData)
            case 400:
                throw APIError.serverError(statusCode: 400, message: "Invalid request")
            case 409:
                throw APIError.serverError(statusCode: 409, message: "Email already registered")
            default:
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Server error")
            }
        } catch let error as APIError {
            throw error
        } catch let error as NSError {
            // Detect specific network errors
            if error.domain == NSURLErrorDomain {
                switch error.code {
                case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                    throw APIError.connectionRefused
                case NSURLErrorTimedOut:
                    throw APIError.timeoutError
                case -1004: // "Could not connect to the server"
                    throw APIError.connectionRefused
                default:
                    throw APIError.networkError(error)
                }
            }
            throw APIError.networkError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func get<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            default:
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Failed to fetch data")
            }
        } catch let error as APIError {
            throw error
        } catch let error as NSError {
            // Detect specific network errors
            if error.domain == NSURLErrorDomain {
                switch error.code {
                case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                    throw APIError.connectionRefused
                case NSURLErrorTimedOut:
                    throw APIError.timeoutError
                case -1004: // "Could not connect to the server"
                    throw APIError.connectionRefused
                default:
                    throw APIError.networkError(error)
                }
            }
            throw APIError.networkError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
}
