//
//  SellerConnectApp.swift
//  SellerConnect
//
//  Created by Ben H on 5/30/26.
//

import SwiftUI

#if targetEnvironment(simulator) || targetEnvironment(macCatalyst)
import SellerConnectBackend
#endif

@main
struct SellerConnectApp: App {
    @State private var serverStarted = false
    @State private var serverError: String?
    
    var body: some Scene {
        WindowGroup {
            if let error = serverError {
                VStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    Text("Backend Error")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                ContentView()
            }
        }
        .onAppear {
            initializeServer()
        }
    }
    
    private func initializeServer() {
        #if targetEnvironment(simulator) || targetEnvironment(macCatalyst)
        Task {
            do {
                try await EmbeddedServer.shared.start()
                serverStarted = true
            } catch {
                serverError = "Failed to start backend server: \(error.localizedDescription)"
                print("Server initialization error: \(error)")
            }
        }
        #else
        // On physical devices, use the embedded server
        Task {
            do {
                try await EmbeddedServer.shared.start()
                serverStarted = true
            } catch {
                serverError = "Failed to start backend server: \(error.localizedDescription)"
                print("Server initialization error: \(error)")
            }
        }
        #endif
    }
}

