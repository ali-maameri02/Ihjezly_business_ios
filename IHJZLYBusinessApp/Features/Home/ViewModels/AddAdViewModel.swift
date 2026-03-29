// Features/Home/ViewModels/AddAdViewModel.swift
import Foundation
import Combine

@MainActor
final class AddAdViewModel: ObservableObject {
    @Published var properties: [MyProperty] = []
    @Published var activeSubscription: ActiveSubscription? = nil
    @Published var isLoading = false
    @Published var togglingId: String? = nil
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    private let apiClient: APIClient
    private let subscriptionService: SubscriptionService

    init() {
        let client = APIClient(baseURLString: "http://31.220.56.155:5050")
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            client.defaultHeaders["Authorization"] = "Bearer \(token)"
        }
        self.apiClient = client
        self.subscriptionService = SubscriptionService(apiClient: client)
    }

    func load() async {
        isLoading = true
        guard let userId = currentUserId() else {
            errorMessage = "تعذّر تحديد هوية المستخدم"
            isLoading = false
            return
        }
        async let propsTask = fetchProperties(ownerId: userId)
        async let activeTask: ActiveSubscription? = try? subscriptionService.fetchActiveSubscription(userId: userId)
        let (props, active) = await (propsTask, activeTask)
        properties = props
        activeSubscription = active
        isLoading = false
    }

    func toggleAd(for property: MyProperty) async {
        togglingId = property.id
        errorMessage = nil
        let newValue = !property.isAd

        if newValue && activeSubscription == nil {
            errorMessage = "يجب الاشتراك في خطة أولاً لتفعيل الإعلانات"
            togglingId = nil
            return
        }
        if newValue, let sub = activeSubscription, sub.remainingAds <= 0 {
            errorMessage = "لقد استنفدت حصة الإعلانات في اشتراكك الحالي"
            togglingId = nil
            return
        }

        do {
            let body = try JSONEncoder().encode(newValue)
            let (data, response) = try await apiClient.postRaw(
                to: "/api/v1/AllProperties/\(property.id)/is-ad",
                body: body,
                contentType: "application/json",
                method: "PATCH"
            )
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            if !(200...299).contains(http.statusCode) {
                let msg = String(data: data, encoding: .utf8) ?? "خطأ غير معروف"
                if msg.contains("MaxAdd") || msg.contains("quota") {
                    throw APIError.badRequest("لقد استنفدت حصة الإعلانات في اشتراكك الحالي")
                }
                if msg.contains("NotFound") || msg.contains("subscription") {
                    throw APIError.badRequest("يجب الاشتراك في خطة أولاً لتفعيل الإعلانات")
                }
                throw APIError.badRequest(msg)
            }
            successMessage = newValue
                ? "تم تفعيل الإعلان لـ \"\(property.title)\""
                : "تم إلغاء الإعلان لـ \"\(property.title)\""
            await load()
        } catch APIError.badRequest(let msg) {
            errorMessage = msg
        } catch {
            errorMessage = "فشل تحديث حالة الإعلان"
        }
        togglingId = nil
    }

    private func currentUserId() -> String? {
        guard let token = UserDefaults.standard.string(forKey: "auth_token"),
              let payload = decodeJWTPayload(token),
              let sub = payload["sub"] as? String ?? payload["nameid"] as? String
        else { return nil }
        return sub
    }

    private func fetchProperties(ownerId: String) async -> [MyProperty] {
        struct RawLocation: Codable { let city: String; let state: String }
        struct RawImage: Codable { let url: String; let isMain: Bool? }
        struct RawProperty: Codable {
            let id: String; let title: String; let price: Double
            let currency: String; let isAd: Bool; let status: String
            let location: RawLocation; let images: [RawImage]?
        }
        do {
            let raw: [RawProperty] = try await apiClient.get(
                to: "/api/v1/AllProperties/by-owner/\(ownerId)"
            )
            return raw.map {
                let mainImage = $0.images?.first(where: { $0.isMain == true })?.url
                    ?? $0.images?.first?.url
                return MyProperty(id: $0.id, title: $0.title, price: $0.price,
                           currency: $0.currency, isAd: $0.isAd, status: $0.status,
                           location: MyPropertyLocation(city: $0.location.city, state: $0.location.state),
                           mainImageUrl: mainImage)
            }
        } catch { return [] }
    }

    private func decodeJWTPayload(_ token: String) -> [String: Any]? {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else { return nil }
        var base64 = parts[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let r = base64.count % 4
        if r > 0 { base64 += String(repeating: "=", count: 4 - r) }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return json
    }
}
