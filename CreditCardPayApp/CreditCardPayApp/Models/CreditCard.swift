//
//  CreditCard.swift
//  CreditCardPayApp
//

import Foundation

struct CreditCard: Identifiable, Codable {
    var id: UUID
    var bank: String
    var cardNumber: String
    var totalDue: Double
    var minimumDue: Double
    var dueDate: Date
    var creditLimit: Double
    var availableCredit: Double
    var transactions: [Transaction]

    init(id: UUID = UUID(), bank: String, cardNumber: String, totalDue: Double, minimumDue: Double, dueDate: Date, creditLimit: Double, availableCredit: Double, transactions: [Transaction] = []) {
        self.id = id
        self.bank = bank
        self.cardNumber = cardNumber
        self.totalDue = totalDue
        self.minimumDue = minimumDue
        self.dueDate = dueDate
        self.creditLimit = creditLimit
        self.availableCredit = availableCredit
        self.transactions = transactions
    }

    var maskedCardNumber: String {
        let components = cardNumber.split(separator: " ")
        if components.count == 4 {
            return "\(components[0]) **** **** \(components[3])"
        }
        return cardNumber
    }

    var isOverdue: Bool {
        return dueDate < Date() && totalDue > 0
    }

    var daysUntilDue: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: dueDate)
        return components.day ?? 0
    }
}
