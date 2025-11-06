//
//  PaymentView.swift
//  CreditCardPayApp
//

import SwiftUI

struct PaymentView: View {
    let card: CreditCard
    @EnvironmentObject var cardViewModel: CardViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedAmount: PaymentAmount = .minimum
    @State private var customAmount = ""
    @State private var selectedUPI: UPIMethod?
    @State private var upiId = ""
    @State private var isProcessing = false
    @State private var showSuccess = false
    @State private var completedPayment: Payment?

    enum PaymentAmount {
        case minimum, total, custom
    }

    enum UPIMethod: String, CaseIterable {
        case googlePay = "Google Pay"
        case phonePe = "PhonePe"
        case paytm = "Paytm"
        case upi = "UPI ID"

        var icon: String {
            switch self {
            case .googlePay: return "g.circle.fill"
            case .phonePe: return "p.circle.fill"
            case .paytm: return "p.circle.fill"
            case .upi: return "indianrupeesign.circle.fill"
            }
        }
    }

    var paymentAmountValue: Double {
        switch selectedAmount {
        case .minimum:
            return card.minimumDue
        case .total:
            return card.totalDue
        case .custom:
            return Double(customAmount) ?? 0
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Payment Summary
                    paymentSummary

                    // Amount Selection
                    amountSelection

                    // UPI Method Selection
                    upiSelection

                    // Pay Button
                    payButton
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Make Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showSuccess) {
                if let payment = completedPayment {
                    PaymentSuccessView(payment: payment, dismiss: {
                        dismiss()
                    })
                }
            }
        }
    }

    private var paymentSummary: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Payment Summary")
                    .font(.headline)
                Spacer()
            }

            VStack(spacing: 12) {
                SummaryRow(label: "Card", value: "\(card.bank) \(card.maskedCardNumber)")
                SummaryRow(label: "Total Due", value: card.totalDue.formatAsCurrency())
                SummaryRow(label: "Minimum Due", value: card.minimumDue.formatAsCurrency())
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private var amountSelection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Amount")
                .font(.headline)

            VStack(spacing: 12) {
                AmountButton(
                    title: "Minimum Due",
                    amount: card.minimumDue,
                    isSelected: selectedAmount == .minimum,
                    action: { selectedAmount = .minimum }
                )

                AmountButton(
                    title: "Total Due",
                    amount: card.totalDue,
                    isSelected: selectedAmount == .total,
                    action: { selectedAmount = .total }
                )

                VStack(alignment: .leading, spacing: 8) {
                    Button(action: { selectedAmount = .custom }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Custom Amount")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Enter amount")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: selectedAmount == .custom ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedAmount == .custom ? .blue : .gray)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())

                    if selectedAmount == .custom {
                        TextField("Enter amount", text: $customAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                }
            }
        }
    }

    private var upiSelection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select UPI Method")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(UPIMethod.allCases, id: \.self) { method in
                    Button(action: { selectedUPI = method }) {
                        VStack(spacing: 8) {
                            Image(systemName: method.icon)
                                .font(.title2)
                                .foregroundColor(selectedUPI == method ? .white : .blue)

                            Text(method.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedUPI == method ? .white : .primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedUPI == method ? Color.blue : Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            if selectedUPI == .upi {
                TextField("Enter UPI ID (e.g., user@paytm)", text: $upiId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
    }

    private var payButton: some View {
        Button(action: processPayment) {
            HStack {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Proceed to Pay")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canPay ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!canPay || isProcessing)
    }

    private var canPay: Bool {
        paymentAmountValue > 0 && selectedUPI != nil && (selectedUPI != .upi || !upiId.isEmpty)
    }

    private func processPayment() {
        isProcessing = true

        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let payment = cardViewModel.makePayment(
                card: card,
                amount: paymentAmountValue,
                upiMethod: selectedUPI?.rawValue ?? "UPI"
            )

            completedPayment = payment
            isProcessing = false
            showSuccess = true
        }
    }
}

struct AmountButton: View {
    let title: String
    let amount: Double
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(amount.formatAsCurrency())
                        .font(.title3)
                        .fontWeight(.bold)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    PaymentView(card: CreditCard(
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
