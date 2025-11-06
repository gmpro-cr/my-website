//
//  Payment.swift
//  CreditCardPayApp
//

import Foundation

struct Payment: Identifiable, Codable {
    var id: UUID
    var transactionId: String
    var cardBank: String
    var cardNumber: String
    var amount: Double
    var upiMethod: String
    var date: Date
    var status: PaymentStatus

    init(id: UUID = UUID(), transactionId: String, cardBank: String, cardNumber: String, amount: Double, upiMethod: String, date: Date = Date(), status: PaymentStatus = .success) {
        self.id = id
        self.transactionId = transactionId
        self.cardBank = cardBank
        self.cardNumber = cardNumber
        self.amount = amount
        self.upiMethod = upiMethod
        self.date = date
        self.status = status
    }

    enum PaymentStatus: String, Codable {
        case success = "Success"
        case pending = "Pending"
        case failed = "Failed"

        var icon: String {
            switch self {
            case .success:
                return "checkmark.circle.fill"
            case .pending:
                return "clock.fill"
            case .failed:
                return "xmark.circle.fill"
            }
        }
    }

    static func generateTransactionId() -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let random = Int.random(in: 100000...999999)
        return "TXN\(timestamp)\(random)"
    }
}
