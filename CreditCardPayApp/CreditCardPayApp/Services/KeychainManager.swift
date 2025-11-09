//
//  KeychainManager.swift
//  CreditCardPayApp
//
//  Secure storage using iOS Keychain
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    private let service = "com.creditcardpay.app"

    // MARK: - Save

    func save(_ data: Data, for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func save(_ string: String, for key: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(data, for: key)
    }

    // MARK: - Retrieve

    func getData(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    func getString(for key: String) -> String? {
        guard let data = getData(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Delete

    func delete(for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    // MARK: - Clear All

    func clearAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    // MARK: - Convenience Methods

    private enum KeychainKey {
        static let authToken = "authToken"
        static let refreshToken = "refreshToken"
        static let userID = "userID"
        static let biometricEnabled = "biometricEnabled"
    }

    func saveToken(_ token: String) -> Bool {
        save(token, for: KeychainKey.authToken)
    }

    func getToken() -> String? {
        getString(for: KeychainKey.authToken)
    }

    func saveRefreshToken(_ token: String) -> Bool {
        save(token, for: KeychainKey.refreshToken)
    }

    func getRefreshToken() -> String? {
        getString(for: KeychainKey.refreshToken)
    }

    func saveUserID(_ id: String) -> Bool {
        save(id, for: KeychainKey.userID)
    }

    func getUserID() -> String? {
        getString(for: KeychainKey.userID)
    }

    func setBiometricEnabled(_ enabled: Bool) -> Bool {
        save(enabled ? "true" : "false", for: KeychainKey.biometricEnabled)
    }

    func isBiometricEnabled() -> Bool {
        getString(for: KeychainKey.biometricEnabled) == "true"
    }

    func logout() -> Bool {
        clearAll()
    }
}
