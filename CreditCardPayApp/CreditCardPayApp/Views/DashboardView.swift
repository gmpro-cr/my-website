//
//  DashboardView.swift
//  CreditCardPayApp
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var cardViewModel = CardViewModel()
    @State private var showingSettings = false
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Section
                    welcomeSection

                    // Payment Reminders
                    if !cardViewModel.overdueCards.isEmpty || !cardViewModel.upcomingDueCards.isEmpty {
                        remindersSection
                    }

                    // Quick Stats
                    statsSection

                    // Credit Cards
                    cardsSection

                    // Recent Transactions
                    recentTransactionsSection

                    // Payment History
                    if !cardViewModel.paymentHistory.isEmpty {
                        paymentHistorySection
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(authViewModel)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back,")
                .font(.title3)
                .foregroundColor(.secondary)

            Text(authViewModel.username.capitalized)
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var remindersSection: some View {
        VStack(spacing: 12) {
            if !cardViewModel.overdueCards.isEmpty {
                ReminderCard(
                    icon: "exclamationmark.triangle.fill",
                    title: "Overdue Payments",
                    description: "You have \(cardViewModel.overdueCards.count) card(s) with overdue payments",
                    color: .red
                )
            }

            if !cardViewModel.upcomingDueCards.isEmpty {
                ReminderCard(
                    icon: "calendar.badge.exclamationmark",
                    title: "Upcoming Payments",
                    description: "You have \(cardViewModel.upcomingDueCards.count) payment(s) due in the next 7 days",
                    color: .orange
                )
            }
        }
    }

    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                icon: "indianrupeesign.circle.fill",
                title: "Total Due",
                value: cardViewModel.totalDue.formatAsCurrency(),
                color: .blue
            )

            StatCard(
                icon: "creditcard.fill",
                title: "Active Cards",
                value: "\(cardViewModel.cards.count)",
                color: .green
            )

            StatCard(
                icon: "calendar",
                title: "Upcoming",
                value: "\(cardViewModel.upcomingPayments)",
                color: .orange
            )

            StatCard(
                icon: "checkmark.circle.fill",
                title: "Paid This Month",
                value: cardViewModel.paidThisMonth.formatAsCurrency(),
                color: .purple
            )
        }
    }

    private var cardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Credit Cards")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                NavigationLink(destination: CardsListView().environmentObject(cardViewModel)) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            ForEach(cardViewModel.cards.prefix(2)) { card in
                NavigationLink(destination: CardDetailView(card: card).environmentObject(cardViewModel)) {
                    CreditCardRow(card: card)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Transactions")
                .font(.title2)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                ForEach(cardViewModel.recentTransactions, id: \.transaction.id) { item in
                    TransactionRow(transaction: item.transaction, cardBank: item.cardBank)
                }
            }
        }
    }

    private var paymentHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment History")
                .font(.title2)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                ForEach(cardViewModel.paymentHistory.prefix(5)) { payment in
                    PaymentHistoryRow(payment: payment)
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
