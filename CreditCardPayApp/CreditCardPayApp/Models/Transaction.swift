//
//  Transaction.swift
//  CreditCardPayApp
//

import Foundation

struct Transaction: Identifiable, Codable {
    var id: UUID
    var name: String
    var date: Date
    var amount: Double
    var category: String

    init(id: UUID = UUID(), name: String, date: Date, amount: Double, category: String = "Shopping") {
        self.id = id
        self.name = name
        self.date = date
        self.amount = amount
        self.category = category
    }

    var icon: String {
        switch category {
        case "Shopping":
            return "cart.fill"
        case "Food":
            return "fork.knife"
        case "Transport":
            return "car.fill"
        case "Entertainment":
            return "tv.fill"
        default:
            return "creditcard.fill"
        }
    }
}
