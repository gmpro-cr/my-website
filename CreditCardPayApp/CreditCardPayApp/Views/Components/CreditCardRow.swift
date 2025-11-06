//
//  CreditCardRow.swift
//  CreditCardPayApp
//

import SwiftUI

struct CreditCardRow: View {
    let card: CreditCard

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(card.bank)
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                if card.isOverdue {
                    Text("OVERDUE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(4)
                }
            }

            Text(card.maskedCardNumber)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .font(.system(.body, design: .monospaced))

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Due")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(card.totalDue.formatAsCurrency())
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(card.isOverdue ? .red : .primary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Due Date")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(card.dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(card.isOverdue ? .red : .primary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

#Preview {
    CreditCardRow(card: CreditCard(
        bank: "HDFC Bank",
        cardNumber: "4532 1234 5678 9012",
        totalDue: 45678,
        minimumDue: 5000,
        dueDate: Date(),
        creditLimit: 200000,
        availableCredit: 154322
    ))
    .padding()
}
