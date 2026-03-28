// Features/Main/ViewModels/BookingsViewModel.swift
import Foundation
import Combine
import SwiftUI

// MARK: - Model — mirrors BookingDto exactly
struct Booking: Identifiable, Codable {
    let id: String
    let clientId: String
    let name: String
    let phoneNumber: String
    let propertyId: String
    let startDate: String
    let endDate: String
    let totalPrice: Double
    let currency: String
    let status: String
    let reservedAt: String

    var bookingStatus: BookingStatus { BookingStatus(rawValue: status) ?? .pending }

    var formattedStartDate: String  { formatDate(startDate) }
    var formattedEndDate: String    { formatDate(endDate) }
    var formattedReservedAt: String { formatDate(reservedAt) }

    var formattedPrice: String {
        String(format: "%.0f %@", totalPrice, currency == "LYD" ? "د.ل" : currency)
    }

    var nightsCount: Int {
        guard let s = parseDate(startDate), let e = parseDate(endDate) else { return 0 }
        return max(0, Calendar.current.dateComponents([.day], from: s, to: e).day ?? 0)
    }

    private func parseDate(_ raw: String) -> Date? {
        let f1 = ISO8601DateFormatter(); f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let f2 = ISO8601DateFormatter(); f2.formatOptions = [.withInternetDateTime]
        return f1.date(from: raw) ?? f2.date(from: raw)
    }

    private func formatDate(_ raw: String) -> String {
        guard let date = parseDate(raw) else { return raw }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale = Locale(identifier: "ar")
        return f.string(from: date)
    }
}

// MARK: - Status enum — values match backend BookingStatus exactly
enum BookingStatus: String, CaseIterable {
    case pending       = "Pending"
    case confirmed     = "Confirmed"
    case lastConfirmed = "LastConfirmed"
    case cancelled     = "Cancelled"
    case rejected      = "Rejected"
    case completed     = "Completed"

    var arabicLabel: String {
        switch self {
        case .pending:       return "قيد الانتظار"
        case .confirmed:     return "مقبول"
        case .lastConfirmed: return "تم الوصول"
        case .cancelled:     return "ملغي"
        case .rejected:      return "مرفوض"
        case .completed:     return "مكتمل"
        }
    }

    var swiftColor: Color {
        switch self {
        case .pending:       return .orange
        case .confirmed:     return .blue
        case .lastConfirmed: return .purple
        case .cancelled:     return .gray
        case .rejected:      return .red
        case .completed:     return .green
        }
    }
}

// MARK: - ViewModel
@MainActor
final class BookingsViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var actionInProgressId: String?

    private var refreshTask: Task<Void, Never>?

    // Filtered lists
    var pending:       [Booking] { bookings.filter { $0.bookingStatus == .pending } }
    var confirmed:     [Booking] { bookings.filter { $0.bookingStatus == .confirmed } }
    var lastConfirmed: [Booking] { bookings.filter { $0.bookingStatus == .lastConfirmed } }
    var rejected:      [Booking] { bookings.filter { $0.bookingStatus == .rejected } }
    var cancelled:     [Booking] { bookings.filter { $0.bookingStatus == .cancelled } }
    var completed:     [Booking] { bookings.filter { $0.bookingStatus == .completed } }

    // Build a fresh APIClient on every call so the token is always current
    private func makeClient() -> APIClient {
        let client = APIClient(baseURLString: "http://31.220.56.155:5050")
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            client.defaultHeaders["Authorization"] = "Bearer \(token)"
        }
        return client
    }

    // MARK: - Fetch  GET /api/v1/Bookings/by-business-owner/{id}
    func fetch() async {
        guard let userId = currentUserId() else {
            errorMessage = "تعذّر تحديد هوية المستخدم. يرجى تسجيل الدخول مجدداً."
            return
        }
        isLoading = bookings.isEmpty
        defer { isLoading = false }
        do {
            let fetched: [Booking] = try await makeClient().get(
                to: "/api/v1/Bookings/by-business-owner/\(userId)"
            )
            bookings = fetched.sorted { $0.reservedAt > $1.reservedAt }
        } catch {
            errorMessage = networkErrorMessage(error)
        }
    }

    // MARK: - Accept → Confirmed
    func accept(_ booking: Booking) async {
        await updateStatus(booking, newStatus: "Confirmed")
    }

    // MARK: - Reject → Rejected
    func reject(_ booking: Booking) async {
        await updateStatus(booking, newStatus: "Rejected")
    }

    // MARK: - PATCH /api/v1/Bookings/{id}/status
    // Body: { "NewStatus": "Confirmed", "Pin": null }
    // Backend uses JsonStringEnumConverter → enum sent as string
    // Returns 204 NoContent on success
    private func updateStatus(_ booking: Booking, newStatus: String) async {
        actionInProgressId = booking.id
        defer { actionInProgressId = nil }
        errorMessage = nil

        struct StatusBody: Encodable {
            let NewStatus: String   // PascalCase matches UpdateBookingStatusRequest record
            let Pin: String?
        }

        do {
            let body = try JSONEncoder().encode(StatusBody(NewStatus: newStatus, Pin: nil))
            let (data, response) = try await makeClient().postRaw(
                to: "/api/v1/Bookings/\(booking.id)/status",
                body: body,
                contentType: "application/json",
                method: "PATCH"
            )
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

            guard (200...299).contains(http.statusCode) else {
                // Backend returns { "error": "...", "message": {...} } on failure
                struct ErrBody: Decodable { let message: String? }
                let msg = (try? JSONDecoder().decode(ErrBody.self, from: data))?.message
                    ?? String(data: data, encoding: .utf8)
                    ?? "خطأ غير معروف"
                throw APIError.badRequest(msg)
            }

            successMessage = newStatus == "Confirmed"
                ? "✓ تم قبول حجز \"\(booking.name)\" بنجاح"
                : "✓ تم رفض حجز \"\(booking.name)\""
            await fetch()

        } catch APIError.badRequest(let msg) {
            errorMessage = msg
        } catch {
            errorMessage = networkErrorMessage(error)
        }
    }

    // MARK: - Auto-refresh every 60 s
    func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 60_000_000_000)
                guard !Task.isCancelled else { return }
                await fetch()
            }
        }
    }

    func stopAutoRefresh() { refreshTask?.cancel() }

    // MARK: - JWT claim extraction
    // Backend sets both JwtRegisteredClaimNames.Sub and ClaimTypes.NameIdentifier
    // "sub" is the reliable short-form key in the raw JWT payload
    private func currentUserId() -> String? {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else { return nil }
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else { return nil }
        var b64 = parts[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let rem = b64.count % 4
        if rem > 0 { b64 += String(repeating: "=", count: 4 - rem) }
        guard let data = Data(base64Encoded: b64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        // "sub" is set via JwtRegisteredClaimNames.Sub in JwtService
        return json["sub"] as? String
    }

    private func networkErrorMessage(_ error: Error) -> String {
        if let urlErr = error as? URLError, urlErr.code == .notConnectedToInternet {
            return "لا يوجد اتصال بالإنترنت"
        }
        return "فشل الاتصال بالخادم. تحقق من الشبكة وحاول مجدداً."
    }
}
