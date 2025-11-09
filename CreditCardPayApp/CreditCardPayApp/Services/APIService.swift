//
//  APIService.swift
//  CreditCardPayApp
//
//  API endpoints and service layer
//

import Foundation

class APIService {
    static let shared = APIService()

    private init() {}

    // MARK: - Authentication

    struct LoginRequest: Codable {
        let username: String
        let password: String
        let deviceId: String
    }

    struct LoginResponse: Codable {
        let token: String
        let refreshToken: String
        let user: UserData
        let expiresIn: Int
    }

    struct UserData: Codable {
        let id: String
        let username: String
        let email: String?
        let phoneNumber: String?
    }

    func login(username: String, password: String) async throws -> LoginResponse {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString

        let request = LoginRequest(
            username: username,
            password: password,
            deviceId: deviceId
        )

        return try await NetworkManager.shared.request(
            endpoint: "/auth/login",
            method: .post,
            body: request
        )
    }

    func refreshToken() async throws -> LoginResponse {
        guard let refreshToken = KeychainManager.shared.getRefreshToken() else {
            throw NetworkError.unauthorized
        }

        struct RefreshRequest: Codable {
            let refreshToken: String
        }

        return try await NetworkManager.shared.request(
            endpoint: "/auth/refresh",
            method: .post,
            body: RefreshRequest(refreshToken: refreshToken)
        )
    }

    // MARK: - Credit Cards

    struct CardsResponse: Codable {
        let cards: [CreditCardDTO]
    }

    struct CreditCardDTO: Codable {
        let id: String
        let bank: String
        let cardNumber: String
        let totalDue: Double
        let minimumDue: Double
        let dueDate: String
        let creditLimit: Double
        let availableCredit: Double
        let transactions: [TransactionDTO]
    }

    struct TransactionDTO: Codable {
        let id: String
        let name: String
        let date: String
        let amount: Double
        let category: String
    }

    func fetchCards() async throws -> CardsResponse {
        return try await NetworkManager.shared.request(
            endpoint: "/cards",
            method: .get
        )
    }

    func fetchCardDetails(cardId: String) async throws -> CreditCardDTO {
        return try await NetworkManager.shared.request(
            endpoint: "/cards/\(cardId)",
            method: .get
        )
    }

    // MARK: - Payments

    struct CreatePaymentRequest: Codable {
        let cardId: String
        let amount: Double
        let upiMethod: String
        let upiId: String?
    }

    struct CreatePaymentResponse: Codable {
        let paymentId: String
        let orderId: String
        let amount: Double
        let currency: String
        let razorpayOrderId: String? // For Razorpay integration
        let status: String
    }

    func createPayment(request: CreatePaymentRequest) async throws -> CreatePaymentResponse {
        return try await NetworkManager.shared.request(
            endpoint: "/payments/create",
            method: .post,
            body: request
        )
    }

    struct VerifyPaymentRequest: Codable {
        let paymentId: String
        let razorpayPaymentId: String?
        let razorpaySignature: String?
    }

    struct VerifyPaymentResponse: Codable {
        let success: Bool
        let transactionId: String
        let status: String
        let message: String
    }

    func verifyPayment(request: VerifyPaymentRequest) async throws -> VerifyPaymentResponse {
        return try await NetworkManager.shared.request(
            endpoint: "/payments/verify",
            method: .post,
            body: request
        )
    }

    func getPaymentHistory() async throws -> [PaymentDTO] {
        struct PaymentHistoryResponse: Codable {
            let payments: [PaymentDTO]
        }

        let response: PaymentHistoryResponse = try await NetworkManager.shared.request(
            endpoint: "/payments/history",
            method: .get
        )

        return response.payments
    }

    struct PaymentDTO: Codable {
        let id: String
        let transactionId: String
        let cardBank: String
        let cardNumber: String
        let amount: Double
        let upiMethod: String
        let date: String
        let status: String
    }

    // MARK: - User Profile

    struct UserProfileResponse: Codable {
        let user: UserData
        let stats: UserStats
    }

    struct UserStats: Codable {
        let totalDue: Double
        let activeCards: Int
        let upcomingPayments: Int
        let paidThisMonth: Double
    }

    func getUserProfile() async throws -> UserProfileResponse {
        return try await NetworkManager.shared.request(
            endpoint: "/user/profile",
            method: .get
        )
    }

    // MARK: - Notifications

    func registerDeviceToken(_ token: String) async throws {
        struct DeviceTokenRequest: Codable {
            let deviceToken: String
            let platform: String = "ios"
        }

        let _: EmptyResponse = try await NetworkManager.shared.request(
            endpoint: "/user/device-token",
            method: .post,
            body: DeviceTokenRequest(deviceToken: token)
        )
    }

    struct EmptyResponse: Codable {}
}

// MARK: - DTO to Model Converters

extension CreditCardDTO {
    func toModel() -> CreditCard {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: dueDate) ?? Date()

        return CreditCard(
            id: UUID(uuidString: id) ?? UUID(),
            bank: bank,
            cardNumber: cardNumber,
            totalDue: totalDue,
            minimumDue: minimumDue,
            dueDate: date,
            creditLimit: creditLimit,
            availableCredit: availableCredit,
            transactions: transactions.map { $0.toModel() }
        )
    }
}

extension TransactionDTO {
    func toModel() -> Transaction {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: self.date) ?? Date()

        return Transaction(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            date: date,
            amount: amount,
            category: category
        )
    }
}

extension APIService.PaymentDTO {
    func toModel() -> Payment {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: self.date) ?? Date()

        return Payment(
            id: UUID(uuidString: id) ?? UUID(),
            transactionId: transactionId,
            cardBank: cardBank,
            cardNumber: cardNumber,
            amount: amount,
            upiMethod: upiMethod,
            date: date,
            status: Payment.PaymentStatus(rawValue: status) ?? .pending
        )
    }
}
