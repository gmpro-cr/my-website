//
//  CardViewModel.swift
//  CreditCardPayApp
//

import Foundation
import SwiftUI

class CardViewModel: ObservableObject {
    @Published var cards: [CreditCard] = []
    @Published var paymentHistory: [Payment] = []

    init() {
        loadSampleData()
        loadPaymentHistory()
    }

    private func loadSampleData() {
        let calendar = Calendar.current

        cards = [
            CreditCard(
                bank: "HDFC Bank",
                cardNumber: "4532 1234 5678 9012",
                totalDue: 45678,
                minimumDue: 5000,
                dueDate: calendar.date(byAdding: .day, value: 9, to: Date())!,
                creditLimit: 200000,
                availableCredit: 154322,
                transactions: [
                    Transaction(name: "Amazon.in", date: calendar.date(byAdding: .day, value: -5, to: Date())!, amount: 3499, category: "Shopping"),
                    Transaction(name: "Swiggy", date: calendar.date(byAdding: .day, value: -4, to: Date())!, amount: 850, category: "Food"),
                    Transaction(name: "Netflix", date: calendar.date(byAdding: .day, value: -3, to: Date())!, amount: 649, category: "Entertainment"),
                    Transaction(name: "Uber", date: calendar.date(byAdding: .day, value: -1, to: Date())!, amount: 380, category: "Transport")
                ]
            ),
            CreditCard(
                bank: "SBI Card",
                cardNumber: "5412 3456 7890 1234",
                totalDue: 23450,
                minimumDue: 2500,
                dueDate: calendar.date(byAdding: .day, value: 12, to: Date())!,
                creditLimit: 150000,
                availableCredit: 126550,
                transactions: [
                    Transaction(name: "Myntra", date: calendar.date(byAdding: .day, value: -8, to: Date())!, amount: 4200, category: "Shopping"),
                    Transaction(name: "BigBasket", date: calendar.date(byAdding: .day, value: -6, to: Date())!, amount: 2800, category: "Shopping"),
                    Transaction(name: "BookMyShow", date: calendar.date(byAdding: .day, value: -5, to: Date())!, amount: 650, category: "Entertainment")
                ]
            ),
            CreditCard(
                bank: "ICICI Bank",
                cardNumber: "6011 9012 3456 7890",
                totalDue: 67890,
                minimumDue: 7500,
                dueDate: calendar.date(byAdding: .day, value: 6, to: Date())!,
                creditLimit: 300000,
                availableCredit: 232110,
                transactions: [
                    Transaction(name: "Flipkart", date: calendar.date(byAdding: .day, value: -11, to: Date())!, amount: 15600, category: "Shopping"),
                    Transaction(name: "Apple Store", date: calendar.date(byAdding: .day, value: -9, to: Date())!, amount: 28999, category: "Shopping"),
                    Transaction(name: "Starbucks", date: calendar.date(byAdding: .day, value: -4, to: Date())!, amount: 750, category: "Food")
                ]
            )
        ]
    }

    private func loadPaymentHistory() {
        if let data = UserDefaults.standard.data(forKey: "paymentHistory"),
           let decoded = try? JSONDecoder().decode([Payment].self, from: data) {
            paymentHistory = decoded
        }
    }

    func savePaymentHistory() {
        if let encoded = try? JSONEncoder().encode(paymentHistory) {
            UserDefaults.standard.set(encoded, forKey: "paymentHistory")
        }
    }

    func makePayment(card: CreditCard, amount: Double, upiMethod: String) -> Payment {
        let transactionId = Payment.generateTransactionId()

        let payment = Payment(
            transactionId: transactionId,
            cardBank: card.bank,
            cardNumber: card.maskedCardNumber,
            amount: amount,
            upiMethod: upiMethod
        )

        // Update card
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index].totalDue -= amount
            cards[index].availableCredit += amount

            if cards[index].totalDue < cards[index].minimumDue {
                cards[index].minimumDue = cards[index].totalDue
            }
        }

        // Save payment
        paymentHistory.insert(payment, at: 0)
        savePaymentHistory()

        return payment
    }

    var totalDue: Double {
        cards.reduce(0) { $0 + $1.totalDue }
    }

    var upcomingPayments: Int {
        cards.filter { $0.daysUntilDue >= 0 && $0.daysUntilDue <= 30 && $0.totalDue > 0 }.count
    }

    var paidThisMonth: Double {
        let calendar = Calendar.current
        let now = Date()

        return paymentHistory.filter { payment in
            calendar.isDate(payment.date, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $1.amount }
    }

    var overdueCards: [CreditCard] {
        cards.filter { $0.isOverdue }
    }

    var upcomingDueCards: [CreditCard] {
        cards.filter { $0.daysUntilDue >= 0 && $0.daysUntilDue <= 7 && $0.totalDue > 0 }
    }

    var recentTransactions: [TransactionWithCard] {
        var allTransactions: [TransactionWithCard] = []

        for card in cards {
            for transaction in card.transactions {
                allTransactions.append(TransactionWithCard(transaction: transaction, cardBank: card.bank))
            }
        }

        return allTransactions.sorted { $0.transaction.date > $1.transaction.date }.prefix(5).map { $0 }
    }
}

struct TransactionWithCard {
    let transaction: Transaction
    let cardBank: String
}
