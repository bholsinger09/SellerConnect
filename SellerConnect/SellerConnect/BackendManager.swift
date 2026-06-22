//
//  BackendManager.swift
//  SellerConnect
//
//  This file bridges the app to the embedded Vapor backend.
//  The backend is optional and only available after the SellerConnectBackend package
//  is added to the Xcode project and linked to the SellerConnect target.
//

import Foundation

#if canImport(SellerConnectBackend)
import SellerConnectBackend

/// Backend manager for embedded Vapor server
class BackendManager {
    static let shared = BackendManager()
    
    var isAvailable: Bool { true }
    
    func start() async throws {
        try await EmbeddedServer.shared.start()
    }
    
    func stop() async {
        await EmbeddedServer.shared.stop()
    }
}
#else

/// Stub backend manager when SellerConnectBackend is not linked
class BackendManager {
    static let shared = BackendManager()
    
    var isAvailable: Bool { false }
    
    func start() async throws {
        print("⚠️  SellerConnectBackend package is not linked to the app.")
        print("Follow QUICKSTART.md to add and link the backend package.")
    }
    
    func stop() async {
        // No-op
    }
}
#endif
