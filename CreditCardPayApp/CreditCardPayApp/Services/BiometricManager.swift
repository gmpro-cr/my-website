//
//  BiometricManager.swift
//  CreditCardPayApp
//
//  Face ID / Touch ID authentication
//

import Foundation
import LocalAuthentication

class BiometricManager {
    static let shared = BiometricManager()

    private init() {}

    enum BiometricType {
        case none
        case touchID
        case faceID

        var displayName: String {
            switch self {
            case .none:
                return "None"
            case .touchID:
                return "Touch ID"
            case .faceID:
                return "Face ID"
            }
        }
    }

    // MARK: - Check Availability

    func biometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            return .none
        }
    }

    func isBiometricAvailable() -> Bool {
        biometricType() != .none
    }

    // MARK: - Authenticate

    func authenticate(reason: String = "Authenticate to access your account") async throws -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                throw BiometricError.fromLAError(error)
            }
            throw BiometricError.notAvailable
        }

        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
        } catch {
            throw BiometricError.fromLAError(error as NSError)
        }
    }

    // MARK: - Authenticate with Passcode Fallback

    func authenticateWithPasscode(reason: String = "Authenticate to access your account") async throws -> Bool {
        let context = LAContext()
        context.localizedFallbackTitle = "Enter Passcode"
        context.localizedCancelTitle = "Cancel"

        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
        } catch {
            throw BiometricError.fromLAError(error as NSError)
        }
    }
}

// MARK: - Biometric Error

enum BiometricError: Error {
    case notAvailable
    case authenticationFailed
    case userCancel
    case userFallback
    case systemCancel
    case passcodeNotSet
    case biometricNotAvailable
    case biometricNotEnrolled
    case biometricLockout
    case unknown(Error)

    var localizedDescription: String {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available on this device"
        case .authenticationFailed:
            return "Authentication failed. Please try again."
        case .userCancel:
            return "Authentication was cancelled"
        case .userFallback:
            return "User chose to enter passcode"
        case .systemCancel:
            return "System cancelled authentication"
        case .passcodeNotSet:
            return "Passcode is not set on this device"
        case .biometricNotAvailable:
            return "Biometric authentication is not available"
        case .biometricNotEnrolled:
            return "No biometric data is enrolled"
        case .biometricLockout:
            return "Biometric authentication is locked. Please use passcode."
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    static func fromLAError(_ error: NSError) -> BiometricError {
        guard let laError = LAError.Code(rawValue: error.code) else {
            return .unknown(error)
        }

        switch laError {
        case .authenticationFailed:
            return .authenticationFailed
        case .userCancel:
            return .userCancel
        case .userFallback:
            return .userFallback
        case .systemCancel:
            return .systemCancel
        case .passcodeNotSet:
            return .passcodeNotSet
        case .biometryNotAvailable:
            return .biometricNotAvailable
        case .biometryNotEnrolled:
            return .biometricNotEnrolled
        case .biometryLockout:
            return .biometricLockout
        default:
            return .unknown(error)
        }
    }
}
