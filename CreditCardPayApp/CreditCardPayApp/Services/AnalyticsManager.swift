//
//  AnalyticsManager.swift
//  CreditCardPayApp
//
//  Analytics and event tracking
//

import Foundation

class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    enum Event: String {
        // Authentication
        case loginSuccess = "login_success"
        case loginFailed = "login_failed"
        case logoutCompleted = "logout_completed"
        case biometricEnabled = "biometric_enabled"
        case biometricDisabled = "biometric_disabled"

        // Navigation
        case screenView = "screen_view"
        case cardSelected = "card_selected"
        case paymentInitiated = "payment_initiated"

        // Payments
        case paymentSuccess = "payment_success"
        case paymentFailed = "payment_failed"
        case paymentCancelled = "payment_cancelled"

        // User Actions
        case settingsOpened = "settings_opened"
        case helpOpened = "help_opened"
        case darkModeToggled = "dark_mode_toggled"

        // Errors
        case networkError = "network_error"
        case apiError = "api_error"
    }

    // MARK: - Log Event

    func logEvent(_ event: Event, parameters: [String: Any]? = nil) {
        var eventData: [String: Any] = [
            "event_name": event.rawValue,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            "device_id": UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        ]

        if let parameters = parameters {
            eventData.merge(parameters) { (_, new) in new }
        }

        // In production, send to your analytics service
        // e.g., Firebase Analytics, Mixpanel, Amplitude, etc.
        print("📊 Analytics Event: \(event.rawValue)")
        print("   Parameters: \(eventData)")

        // For production, integrate with Firebase Analytics
        // Analytics.logEvent(event.rawValue, parameters: eventData)
    }

    // MARK: - Log Screen View

    func logScreenView(_ screenName: String, screenClass: String? = nil) {
        logEvent(.screenView, parameters: [
            "screen_name": screenName,
            "screen_class": screenClass ?? screenName
        ])
    }

    // MARK: - Set User Properties

    func setUserProperty(_ value: String, forName name: String) {
        // In production, set user properties
        print("👤 User Property: \(name) = \(value)")

        // For Firebase Analytics
        // Analytics.setUserProperty(value, forName: name)
    }

    // MARK: - Set User ID

    func setUserID(_ userId: String) {
        // In production, set user ID for tracking
        print("👤 User ID: \(userId)")

        // For Firebase Analytics
        // Analytics.setUserID(userId)
    }
}
