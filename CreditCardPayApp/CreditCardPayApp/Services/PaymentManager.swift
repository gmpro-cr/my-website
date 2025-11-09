//
//  PaymentManager.swift
//  CreditCardPayApp
//
//  Payment gateway integration (Razorpay)
//

import Foundation
import UIKit

class PaymentManager: NSObject {
    static let shared = PaymentManager()

    private override init() {
        super.init()
    }

    // Razorpay configuration
    // Replace with your actual Razorpay keys
    private let razorpayKeyId = "YOUR_RAZORPAY_KEY_ID"
    private let razorpayKeySecret = "YOUR_RAZORPAY_KEY_SECRET"

    // MARK: - Process Payment

    struct PaymentRequest {
        let amount: Double
        let cardId: String
        let cardBank: String
        let upiMethod: String
        let upiId: String?
    }

    struct PaymentResult {
        let success: Bool
        let transactionId: String?
        let razorpayPaymentId: String?
        let razorpaySignature: String?
        let errorMessage: String?
    }

    func processPayment(_ request: PaymentRequest) async throws -> PaymentResult {
        // Step 1: Create order on backend
        let createPaymentRequest = APIService.CreatePaymentRequest(
            cardId: request.cardId,
            amount: request.amount,
            upiMethod: request.upiMethod,
            upiId: request.upiId
        )

        let paymentResponse = try await APIService.shared.createPayment(request: createPaymentRequest)

        // Step 2: Initialize Razorpay checkout
        // In production, you would use Razorpay SDK here
        // For now, simulating payment processing

        do {
            // Simulate payment processing
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

            // Generate mock Razorpay response
            let razorpayPaymentId = "pay_\(UUID().uuidString.prefix(14))"
            let razorpaySignature = generateSignature(
                orderId: paymentResponse.razorpayOrderId ?? "",
                paymentId: razorpayPaymentId
            )

            // Step 3: Verify payment on backend
            let verifyRequest = APIService.VerifyPaymentRequest(
                paymentId: paymentResponse.paymentId,
                razorpayPaymentId: razorpayPaymentId,
                razorpaySignature: razorpaySignature
            )

            let verifyResponse = try await APIService.shared.verifyPayment(request: verifyRequest)

            if verifyResponse.success {
                // Log successful payment
                AnalyticsManager.shared.logEvent(.paymentSuccess, parameters: [
                    "amount": request.amount,
                    "upi_method": request.upiMethod,
                    "card_bank": request.cardBank
                ])

                return PaymentResult(
                    success: true,
                    transactionId: verifyResponse.transactionId,
                    razorpayPaymentId: razorpayPaymentId,
                    razorpaySignature: razorpaySignature,
                    errorMessage: nil
                )
            } else {
                throw PaymentError.verificationFailed(verifyResponse.message)
            }

        } catch {
            // Log payment failure
            AnalyticsManager.shared.logEvent(.paymentFailed, parameters: [
                "amount": request.amount,
                "error": error.localizedDescription
            ])

            throw error
        }
    }

    // MARK: - UPI Payment

    func processUPIPayment(_ request: PaymentRequest) async throws -> PaymentResult {
        // UPI-specific payment flow
        // This would integrate with UPI apps installed on device

        guard let upiId = request.upiId, !upiId.isEmpty else {
            throw PaymentError.invalidUPIId
        }

        // Validate UPI ID format
        guard isValidUPIId(upiId) else {
            throw PaymentError.invalidUPIId
        }

        return try await processPayment(request)
    }

    // MARK: - Helper Methods

    private func generateSignature(orderId: String, paymentId: String) -> String {
        // In production, this would use HMAC SHA256 with Razorpay secret
        let combined = "\(orderId)|\(paymentId)"
        return combined.data(using: .utf8)?.base64EncodedString() ?? ""
    }

    private func isValidUPIId(_ upiId: String) -> Bool {
        // Basic UPI ID validation
        let upiRegex = "^[a-zA-Z0-9._-]+@[a-zA-Z]{3,}$"
        let upiPredicate = NSPredicate(format: "SELF MATCHES %@", upiRegex)
        return upiPredicate.evaluate(with: upiId)
    }

    // MARK: - Get Payment Status

    func getPaymentStatus(paymentId: String) async throws -> String {
        // Query payment status from backend
        struct PaymentStatusResponse: Codable {
            let status: String
        }

        let response: PaymentStatusResponse = try await NetworkManager.shared.request(
            endpoint: "/payments/\(paymentId)/status",
            method: .get
        )

        return response.status
    }
}

// MARK: - Payment Error

enum PaymentError: Error {
    case invalidAmount
    case invalidUPIId
    case paymentCancelled
    case paymentFailed(String)
    case verificationFailed(String)
    case networkError
    case unknown

    var localizedDescription: String {
        switch self {
        case .invalidAmount:
            return "Invalid payment amount"
        case .invalidUPIId:
            return "Invalid UPI ID format"
        case .paymentCancelled:
            return "Payment was cancelled"
        case .paymentFailed(let message):
            return "Payment failed: \(message)"
        case .verificationFailed(let message):
            return "Payment verification failed: \(message)"
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
