//
//  CreditCardPayAppApp.swift
//  CreditCardPayApp
//
//  Created by AI Assistant
//

import SwiftUI

@main
struct CreditCardPayAppApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                DashboardView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
