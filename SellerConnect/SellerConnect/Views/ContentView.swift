//
//  ContentView.swift
//  SellerConnect
//
//  Created by Ben H on 5/30/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                Text("SellerConnect")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                Spacer()
                VStack(spacing: 20) {
                    NavigationLink(destination: RegisterView()) {
                        Text("Register")
                            .fontWeight(.medium)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                    
                    Button(action: {
                        // Handle login action
                    }) {
                        Text("Log In")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
