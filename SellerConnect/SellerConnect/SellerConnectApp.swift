//
//  SellerConnectApp.swift
//  SellerConnect
//
//  Created by Ben H on 5/30/26.
//

import SwiftUI

@main
struct SellerConnectApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var serverStarted = false
    @State private var serverError: String?
    
    var body: some View {
        Group {
            if let error = serverError {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.red)
                    Text("Backend Error")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                    
                    Button("Retry") {
                        Task {
                            await initializeServer()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else {
                ContentView()
            }
        }
        .onAppear {
            Task {
                await initializeServer()
            }
        }
    }
    
    private func initializeServer() async {
        do {
            try await BackendManager.shared.start()
            serverStarted = true
            print("✅ Server initialized")
        } catch {
            serverError = "Failed to start backend server: \(error.localizedDescription)"
            print("❌ Server initialization error: \(error)")
        }
    }
}

