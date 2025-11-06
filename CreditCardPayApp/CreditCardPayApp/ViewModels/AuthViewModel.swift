//
//  AuthViewModel.swift
//  CreditCardPayApp
//

import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var username = ""
    @Published var errorMessage = ""
    @Published var isLoading = false

    private let validUsername = "demo"
    private let validPassword = "demo123"

    func login(username: String, password: String) {
        isLoading = true
        errorMessage = ""

        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }

            if username == self.validUsername && password == self.validPassword {
                withAnimation {
                    self.isAuthenticated = true
                    self.username = username
                }
                UserDefaults.standard.set(true, forKey: "isAuthenticated")
                UserDefaults.standard.set(username, forKey: "username")
            } else {
                self.errorMessage = "Invalid username or password"
            }

            self.isLoading = false
        }
    }

    func logout() {
        withAnimation {
            isAuthenticated = false
            username = ""
        }
        UserDefaults.standard.set(false, forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "username")
    }

    func checkAuthStatus() {
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        username = UserDefaults.standard.string(forKey: "username") ?? ""
    }

    init() {
        checkAuthStatus()
    }
}
