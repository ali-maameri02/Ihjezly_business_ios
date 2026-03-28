// Features/Profile/ViewModels/NotificationsViewModel.swift
import Foundation
import SwiftUI
import Combine

// MARK: - Model matching backend NotificationDto exactly
struct NotificationItem: Identifiable, Codable {
    let id: String
    let userId: String
    let message: String
    let sentAt: String
    var isRead: Bool

    // Derive a short title from the first sentence of the message
    var title: String {
        let first = message.components(separatedBy: ".").first ?? message
        return String(first.prefix(50))
    }

    var timeAgo: String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let iso2 = ISO8601DateFormatter()
        iso2.formatOptions = [.withInternetDateTime]
        guard let date = iso.date(from: sentAt) ?? iso2.date(from: sentAt) else { return sentAt }
        let diff = Date().timeIntervalSince(date)
        switch diff {
        case ..<60:        return "الآن"
        case ..<3600:      return "منذ \(Int(diff / 60)) دقيقة"
        case ..<86400:     return "منذ \(Int(diff / 3600)) ساعة"
        case ..<604800:    return "منذ \(Int(diff / 86400)) يوم"
        default:
            let f = DateFormatter()
            f.dateStyle = .medium
            f.locale = Locale(identifier: "ar")
            return f.string(from: date)
        }
    }
}

// MARK: - ViewModel
@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    var unreadCount: Int { notifications.filter { !$0.isRead }.count }

    private let apiClient: APIClient
    private var refreshTask: Task<Void, Never>?

    init() {
        let client = APIClient(baseURLString: "http://31.220.56.155:5050")
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            client.defaultHeaders["Authorization"] = "Bearer \(token)"
        }
        self.apiClient = client
    }

    // MARK: Fetch  GET /api/v1/Notifications/user/{userId}
    func loadNotifications() {
        Task { await fetch() }
    }

    func fetch() async {
        guard let userId = currentUserId() else { return }
        isLoading = true
        do {
            // Backend returns Result<List<NotificationDto>> wrapped in a value field
            struct Wrapper: Codable { let value: [NotificationItem]? }
            let raw = try await apiClient.get(to: "/api/v1/Notifications/user/\(userId)") as Wrapper
            notifications = (raw.value ?? []).sorted { $0.sentAt > $1.sentAt }
        } catch {
            // Try direct array decode (backend may return plain array)
            if let items: [NotificationItem] = try? await apiClient.get(to: "/api/v1/Notifications/user/\(userId)") {
                notifications = items.sorted { $0.sentAt > $1.sentAt }
            }
        }
        isLoading = false
    }

    // MARK: Mark single as read  PATCH /api/v1/Notifications/{id}/read
    func markAsRead(_ item: NotificationItem) async {
        guard !item.isRead else { return }
        if let idx = notifications.firstIndex(where: { $0.id == item.id }) {
            notifications[idx].isRead = true
        }
        _ = try? await apiClient.patchRaw(to: "/api/v1/Notifications/\(item.id)/read")
    }

    // MARK: Mark all as read  POST /api/v1/Notifications/read-all
    func markAllAsRead() async {
        guard let userId = currentUserId() else { return }
        notifications.indices.forEach { notifications[$0].isRead = true }
        let body = try? JSONEncoder().encode(userId)
        _ = try? await apiClient.postRaw(
            to: "/api/v1/Notifications/read-all",
            body: body ?? Data(),
            contentType: "application/json"
        )
    }

    // MARK: Delete  DELETE /api/v1/Notifications/{id}
    func delete(_ item: NotificationItem) async {
        notifications.removeAll { $0.id == item.id }
        _ = try? await apiClient.patchRaw(to: "/api/v1/Notifications/\(item.id)")
        // patchRaw reused with DELETE — use dedicated delete helper
        await deleteRequest(id: item.id)
    }

    // MARK: Start auto-refresh every 30 s
    func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                if !Task.isCancelled { await fetch() }
            }
        }
    }

    func stopAutoRefresh() { refreshTask?.cancel() }

    // MARK: Helpers
    private func deleteRequest(id: String) async {
        var urlComponents = URLComponents(string: "http://31.220.56.155:5050")!
        urlComponents.path = "/api/v1/Notifications/\(id)"
        guard let url = urlComponents.url else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        _ = try? await URLSession.shared.data(for: req)
    }

    private func currentUserId() -> String? {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else { return nil }
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
        return json["sub"] as? String ?? json["nameid"] as? String
    }
}
