//
//  NetworkManager.swift
//  CreditCardPayApp
//
//  Network layer for API communication
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case unauthorized
    case serverError(Int)
    case noInternet

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized. Please login again."
        case .serverError(let code):
            return "Server error: \(code)"
        case .noInternet:
            return "No internet connection. Please check your network."
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()

    // Change this to your production API URL
    private let baseURL = "https://api.creditcardpay.app/v1"

    private var cancellables = Set<AnyCancellable>()

    private init() {}

    // MARK: - Generic Request
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {

        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30

        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add auth token if available
        if let token = KeychainManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add custom headers
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        // Add body if present
        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }

        // Check internet connectivity
        guard NetworkMonitor.shared.isConnected else {
            throw NetworkError.noInternet
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    return decoded
                } catch {
                    throw NetworkError.decodingFailed(error)
                }
            case 401:
                throw NetworkError.unauthorized
            case 400...499:
                throw NetworkError.serverError(httpResponse.statusCode)
            case 500...599:
                throw NetworkError.serverError(httpResponse.statusCode)
            default:
                throw NetworkError.invalidResponse
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
}

// MARK: - Network Monitor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published var isConnected = true

    private init() {
        // In production, use NWPathMonitor from Network framework
        // For now, simplified version
    }

    func startMonitoring() {
        // Monitor network changes
    }
}
