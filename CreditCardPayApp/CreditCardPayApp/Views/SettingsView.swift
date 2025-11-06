//
//  SettingsView.swift
//  CreditCardPayApp
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationView {
            List {
                // Appearance Section
                Section {
                    Toggle(isOn: $isDarkMode) {
                        HStack {
                            Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(isDarkMode ? .purple : .orange)
                            Text("Dark Mode")
                        }
                    }
                } header: {
                    Text("Appearance")
                }

                // Account Section
                Section {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text(authViewModel.username)
                            .foregroundColor(.secondary)
                    }

                    Button(action: { showLogoutAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(.red)
                            Text("Logout")
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Text("Account")
                }

                // Help Section
                Section {
                    NavigationLink(destination: HelpView()) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Help & FAQ")
                        }
                    }

                    HStack {
                        Image(systemName: "info.circle")
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Support")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    authViewModel.logout()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
}

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                FAQItem(
                    question: "How to make a payment?",
                    answer: "Click on any credit card, view the details, and tap 'Pay Now'. Select your payment amount and UPI method to complete the payment."
                )

                FAQItem(
                    question: "What UPI methods are supported?",
                    answer: "We support Google Pay, PhonePe, Paytm, and direct UPI ID payments."
                )

                FAQItem(
                    question: "How do I view my payment history?",
                    answer: "All your payment history is displayed on the dashboard. You can see transaction IDs, amounts, and payment methods used."
                )

                FAQItem(
                    question: "When should I pay my credit card bill?",
                    answer: "You should pay at least the minimum due amount before the due date to avoid late fees. Paying the total due amount helps you avoid interest charges."
                )

                FAQItem(
                    question: "Is my data secure?",
                    answer: "Yes, all your data is stored locally on your device and is not sent to any external servers."
                )

                FAQItem(
                    question: "Demo Credentials",
                    answer: "Username: demo\nPassword: demo123"
                )
            }
            .padding()
        }
        .navigationTitle("Help & FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FAQItem: View {
    let question: String
    let answer: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.headline)

            Text(answer)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
