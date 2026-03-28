// Data/Services/SubscriptionService.swift
import Foundation

final class SubscriptionService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    // GET /api/v1/Subscriptions/plans
    func fetchPlans() async throws -> [SubscriptionPlan] {
        try await apiClient.get(to: "/api/v1/Subscriptions/plans")
    }

    // GET /api/v1/Subscriptions/active/{userId}
    func fetchActiveSubscription(userId: String) async throws -> ActiveSubscription? {
        let response: ActiveSubscriptionResponse = try await apiClient.get(
            to: "/api/v1/Subscriptions/active/\(userId)"
        )
        return response.isSuccess ? response.value : nil
    }

    // POST /api/v1/Subscriptions
    func subscribe(businessOwnerId: String, planId: String) async throws -> String {
        let body = CreateSubscriptionRequest(
            businessOwnerId: businessOwnerId,
            planId: planId,
            startDate: ISO8601DateFormatter().string(from: Date())
        )
        let data = try JSONEncoder().encode(body)
        let (responseData, response) = try await apiClient.postRaw(
            to: "/api/v1/Subscriptions",
            body: data,
            contentType: "application/json"
        )
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        if !(200...299).contains(http.statusCode) {
            let msg = String(data: responseData, encoding: .utf8) ?? "خطأ غير معروف"
            throw APIError.badRequest(msg)
        }
        return String(data: responseData, encoding: .utf8) ?? ""
    }

    // PATCH /api/v1/Subscriptions/{subscriptionId}/renew/{planId}
    func renew(subscriptionId: String, planId: String) async throws {
        let (responseData, response) = try await apiClient.patchRaw(
            to: "/api/v1/Subscriptions/\(subscriptionId)/renew/\(planId)"
        )
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        if !(200...299).contains(http.statusCode) {
            let msg = String(data: responseData, encoding: .utf8) ?? "خطأ غير معروف"
            throw APIError.badRequest(msg)
        }
    }
}
