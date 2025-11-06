//
//  CardDetailView.swift
//  CreditCardPayApp
//

import SwiftUI

struct CardDetailView: View {
    let card: CreditCard
    @EnvironmentObject var cardViewModel: CardViewModel
    @State private var showingPayment = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Card Header
                cardHeader

                // Payment Details
                paymentDetails

                // Transactions
                transactionsSection

                // Pay Button
                if card.totalDue > 0 {
                    Button(action: { showingPayment = true }) {
                        Text("Pay Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Card Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPayment) {
            PaymentView(card: card)
                .environmentObject(cardViewModel)
        }
    }

    private var cardHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(card.bank)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(card.maskedCardNumber)
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .font(.system(.title3, design: .monospaced))

            HStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Due")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))

                    Text(card.totalDue.formatAsCurrency())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Minimum Due")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))

                    Text(card.minimumDue.formatAsCurrency())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }

    private var paymentDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Details")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                DetailItem(label: "Due Date", value: card.dueDate.formatted(date: .abbreviated, time: .omitted))
                DetailItem(label: "Credit Limit", value: card.creditLimit.formatAsCurrency())
                DetailItem(label: "Available Credit", value: card.availableCredit.formatAsCurrency())
                DetailItem(label: "Used Credit", value: (card.creditLimit - card.availableCredit).formatAsCurrency())
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Transactions")
                .font(.headline)

            if card.transactions.isEmpty {
                Text("No recent transactions")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(card.transactions) { transaction in
                    TransactionRow(transaction: transaction, cardBank: card.bank)
                }
            }
        }
    }
}

struct DetailItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemGroupedBackground))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationView {
        CardDetailView(card: CreditCard(
            bank: "HDFC Bank",
            cardNumber: "4532 1234 5678 9012",
            totalDue: 45678,
            minimumDue: 5000,
            dueDate: Date(),
            creditLimit: 200000,
            availableCredit: 154322
        ))
        .environmentObject(CardViewModel())
    }
}
