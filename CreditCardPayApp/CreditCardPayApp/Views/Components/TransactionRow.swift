//
//  TransactionRow.swift
//  CreditCardPayApp
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    let cardBank: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: transaction.icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack(spacing: 8) {
                    Text(cardBank)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text("-\(transaction.amount.formatAsCurrency())")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

struct PaymentHistoryRow: View {
    let payment: Payment

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: payment.status.icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.green)
                .cornerRadius(22)

            VStack(alignment: .leading, spacing: 4) {
                Text("Payment to \(payment.cardBank)")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                HStack(spacing: 8) {
                    Text(payment.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(payment.upiMethod)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text("Txn: \(payment.transactionId)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .font(.system(.caption2, design: .monospaced))
            }

            Spacer()

            Text("-\(payment.amount.formatAsCurrency())")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

// Currency Formatter Extension
extension Double {
    func formatAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "₹0"
    }
}

#Preview {
    VStack(spacing: 12) {
        TransactionRow(
            transaction: Transaction(name: "Amazon.in", date: Date(), amount: 3499),
            cardBank: "HDFC Bank"
        )

        PaymentHistoryRow(
            payment: Payment(
                transactionId: "TXN1234567890",
                cardBank: "HDFC Bank",
                cardNumber: "4532 **** **** 9012",
                amount: 5000,
                upiMethod: "Google Pay"
            )
        )
    }
    .padding()
}
