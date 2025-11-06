//
//  PaymentSuccessView.swift
//  CreditCardPayApp
//

import SwiftUI

struct PaymentSuccessView: View {
    let payment: Payment
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Success Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            VStack(spacing: 12) {
                Text("Payment Successful!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Your payment has been processed successfully")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Payment Details
            VStack(spacing: 16) {
                HStack {
                    Text("Amount Paid")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(payment.amount.formatAsCurrency())
                        .fontWeight(.bold)
                }

                HStack {
                    Text("Payment Method")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(payment.upiMethod)
                        .fontWeight(.medium)
                }

                HStack {
                    Text("Card")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(payment.cardBank)
                        .fontWeight(.medium)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Transaction ID")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(payment.transactionId)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)

            Spacer()

            Button(action: dismiss) {
                Text("Done")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

#Preview {
    PaymentSuccessView(
        payment: Payment(
            transactionId: "TXN1234567890",
            cardBank: "HDFC Bank",
            cardNumber: "4532 **** **** 9012",
            amount: 5000,
            upiMethod: "Google Pay"
        ),
        dismiss: {}
    )
}
