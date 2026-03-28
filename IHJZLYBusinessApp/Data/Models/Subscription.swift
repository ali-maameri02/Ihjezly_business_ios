// Data/Models/Subscription.swift
import Foundation

struct SubscriptionPlan: Codable, Identifiable {
    let id: String
    let name: String
    let duration: String       // TimeSpan comes as "DD.HH:MM:SS" string from .NET
    let amount: Double
    let currency: String
    let isActive: Bool
    let maxAds: Int

    // Derive human-readable duration from .NET TimeSpan string (e.g. "30.00:00:00" = 30 days)
    var durationInDays: Int {
        // Format: "D.HH:MM:SS" or "HH:MM:SS"
        let parts = duration.components(separatedBy: ".")
        if parts.count >= 2, let days = Int(parts[0]) {
            return days
        }
        return 0
    }

    var formattedDuration: String {
        let days = durationInDays
        if days == 30 { return "شهر واحد" }
        if days == 90 { return "3 أشهر" }
        if days == 180 { return "6 أشهر" }
        if days == 365 { return "سنة كاملة" }
        return "\(days) يوم"
    }

    var formattedPrice: String {
        String(format: "%.0f %@", amount, currency == "LYD" ? "د.ل" : currency)
    }
}

struct ActiveSubscription: Codable {
    let id: String
    let businessOwnerId: String
    let planId: String
    let startDate: String
    let endDate: String
    let price: Double
    let currency: String
    let isActive: Bool
    let usedAds: Int
    let maxAds: Int

    var remainingAds: Int { maxAds - usedAds }

    var formattedEndDate: String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let iso2 = ISO8601DateFormatter()
        iso2.formatOptions = [.withInternetDateTime]
        let date = iso.date(from: endDate) ?? iso2.date(from: endDate)
        guard let d = date else { return endDate }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale = Locale(identifier: "ar")
        return f.string(from: d)
    }
}

// POST /api/v1/Subscriptions body
struct CreateSubscriptionRequest: Codable {
    let businessOwnerId: String
    let planId: String
    let startDate: String   // ISO8601

    enum CodingKeys: String, CodingKey {
        case businessOwnerId = "BusinessOwnerId"
        case planId          = "PlanId"
        case startDate       = "StartDate"
    }
}

// Wrapper for GET active/{userId} response
struct ActiveSubscriptionResponse: Codable {
    let isSuccess: Bool
    let isFailure: Bool
    let value: ActiveSubscription?
}
