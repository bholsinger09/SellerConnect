//
//  ContentViewModel.swift
//  SellerConnect
//
//  Created by Ben H on 6/1/26.
//

import Foundation

@MainActor
class ContentViewModel: ObservableObject {
    @Published var showRegister = false
    @Published var showLogin = false
    @Published var isLoggedIn = false
    @Published var currentUser: User?
}
