// Features/Main/ViewModels/WalletViewModel.swift
import Foundation
import Combine
import SwiftUI

// MARK: - DTOs matching backend exactly

struct WalletDto: Codable {
    let walletId: String
    let userId: String
    let amount: Double
    let currency: String

    var formattedBalance: String {
        String(format: "%.2f %@", amount, currency == "LYD" ? "د.ل" : currency)
    }
}

struct TransactionDto: Identifiable, Codable {
    let id: String
    let walletId: String
    let amount: Double
    let currency: String
    let timestamp: String
    let description: String

    var isCredit: Bool { amount >= 0 }

    var formattedAmount: String {
        let sign = amount >= 0 ? "+" : ""
        return String(format: "%@%.2f %@", sign, amount, currency == "LYD" ? "د.ل" : currency)
    }

    var formattedDate: String {
        let f1 = ISO8601DateFormatter(); f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let f2 = ISO8601DateFormatter(); f2.formatOptions = [.withInternetDateTime]
        guard let date = f1.date(from: timestamp) ?? f2.date(from: timestamp) else { return timestamp }
        let df = DateFormatter(); df.dateStyle = .medium; df.timeStyle = .short
        df.locale = Locale(identifier: "ar")
        return df.string(from: date)
    }
}

// MARK: - ViewModel

@MainActor
final class WalletViewModel: ObservableObject {
    @Published var wallet: WalletDto?
    @Published var transactions: [TransactionDto] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // Sadad state
    @Published var sadadSessionId: String?
    @Published var sadadIsLoading = false

    // Edfali state
    @Published var edfaliSessionId: String?
    @Published var edfaliIsLoading = false

    // Masarat state
    @Published var masaratTransactionId: String?
    @Published var masaratIsLoading = false

    // Prepaid state
    @Published var prepaidIsLoading = false

    private func makeClient() -> APIClient {
        let client = APIClient(baseURLString: "http://31.220.56.155:5050")
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            client.defaultHeaders["Authorization"] = "Bearer \(token)"
        }
        return client
    }

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
        return json["sub"] as? String
    }

    // MARK: - Fetch wallet + transactions together

    func fetchAll() async {
        isLoading = true
        defer { isLoading = false }
        async let walletTask: () = fetchWallet()
        async let txTask: () = fetchTransactions()
        _ = await (walletTask, txTask)
    }

    // GET /api/v1/Wallets/user  (uses JWT context — no userId in path)
    func fetchWallet() async {
        do {
            wallet = try await makeClient().get(to: "/api/v1/Wallets/user")
        } catch {
            errorMessage = "فشل تحميل بيانات المحفظة"
        }
    }

    // GET /api/v1/Transactions/by-user/{userId}
    func fetchTransactions() async {
        guard let userId = currentUserId() else {
            errorMessage = "تعذّر تحديد هوية المستخدم"
            return
        }
        do {
            let fetched: [TransactionDto] = try await makeClient().get(
                to: "/api/v1/Transactions/by-user/\(userId)"
            )
            transactions = fetched.sorted { $0.timestamp > $1.timestamp }
        } catch {
            errorMessage = "فشل تحميل سجل المعاملات"
        }
    }

    // MARK: - Sadad
    // POST /api/v1/Sadad/initiate  body: { Msisdn, BirthYear, Amount }
    // Returns: { sessionId: String }
    func sadadInitiate(msisdn: String, birthYear: String, amount: Double) async {
        sadadIsLoading = true
        defer { sadadIsLoading = false }
        struct Body: Encodable { let Msisdn: String; let BirthYear: String; let Amount: Double }
        struct Resp: Decodable { let sessionId: String }
        do {
            let body = try JSONEncoder().encode(Body(Msisdn: msisdn, BirthYear: birthYear, Amount: amount))
            let (data, response) = try await makeClient().postRaw(
                to: "/api/v1/Sadad/initiate", body: body, contentType: "application/json"
            )
            try assertSuccess(data: data, response: response)
            sadadSessionId = try JSONDecoder().decode(Resp.self, from: data).sessionId
        } catch { errorMessage = apiErrorMessage(error) }
    }

    // POST /api/v1/Sadad/confirm  body: { TransactionId, Otp }
    // Returns: { value: String }
    func sadadConfirm(otp: String) async {
        guard let sessionId = sadadSessionId else { return }
        sadadIsLoading = true
        defer { sadadIsLoading = false }
        struct Body: Encodable { let TransactionId: String; let Otp: String }
        do {
            let body = try JSONEncoder().encode(Body(TransactionId: sessionId, Otp: otp))
            let (data, response) = try await makeClient().postRaw(
                to: "/api/v1/Sadad/confirm", body: body, contentType: "application/json"
            )
            try assertSuccess(data: data, response: response)
            sadadSessionId = nil
            successMessage = "تم شحن المحفظة عبر سداد بنجاح ✓"
            await fetchAll()
        } catch { errorMessage = apiErrorMessage(error) }
    }

    // POST /api/v1/Sadad/otp/resend  body: { TransactionId }
    func sadadResendOtp() async {
        guard let sessionId = sadadSessionId else { return }
        struct Body: Encodable { let TransactionId: String }
        do {
            let body = try JSONEncoder().encode(Body(TransactionId: sessionId))
            let (data, response) = try await makeClient().postRaw(
                to: "/api/v1/Sadad/otp/resend", body: body, contentType: "application/json"
            )
            try assertSuccess(data: data, response: response)
            successMessage = "تم إعادة إرسال رمز التحقق"
        } catch { errorMessage = apiErrorMessage(error) }
    }

    // MARK: - Edfali (إدفعلي)
    // POST /api/v1/Edfali/initiate  body: { UserId, CustomerMobile, Amount }
    // Returns: { SessionIdOrError: { value: String } }
    func edfaliInitiate(mobile: String, amount: Double) async {
        guard let userId = currentUserId() else { errorMessage = "تعذّر تحديد هوية المستخدم"; return }
        edfaliIsLoading = true
        defer { edfaliIsLoading = false }
        struct Body: Encodable { let UserId: String; let CustomerMobile: String; let Amount: Double }
        struct Resp: Decodable {
            struct Inner: Decodable { let value: String? }
            let sessionIdOrError: Inner?
        }
        do {
            let body = try JSONEncoder().encode(Body(UserId: userId, CustomerMobile: mobile, Amount: amount))
            let (data, response) = try await makeClient().postRaw(
                to: "/api/v1/Edfali/initiate", body: body, contentType: "application/json"
            )
            try assertSuccess(data: data, response: response)
            let decoder = JSONDecoder(); decoder.keyDecodingStrategy = .convertFromSnakeCase
            // Backend wraps in { SessionIdOrError: { isSuccess, value, ... } }
            // We just need the session string — parse raw
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let inner = json["sessionIdOrError"] as? [String: Any],
               let val = inner["value"] as? String {
                edfaliSessionId = val
            } else {
                throw APIError.badRequest("فشل استخراج معرف الجلسة")
            }
        } catch { errorMessage = apiErrorMessage(error) }
    }

    // POST /api/v1/Edfali/confirm  body: { ConfirmationPin, SessionId }
    // Returns: { value: String }
    func edfaliConfirm(pin: String) async {
        guard let sessionId = edfaliSessionId else { return }
        edfaliIsLoading = true
        defer { edfaliIsLoading = false }
        struct Body: Encodable { let ConfirmationPin: String; let SessionId: String }
        do {
            let body = try JSONEncoder().encode(Body(ConfirmationPin: pin, SessionId: sessionId))
            let (data, response) = try await makeClient().postRaw(
                to: "/api/v1/Edfali/confirm", body: body, contentType: "application/json"
            )
            try assertSuccess(data: data, response: response)
            edfaliSessionId = nil
            successMessage = "تم شحن المحفظة عبر إدفعلي بنجاح ✓"
            await fetchAll()
        } catch { errorMessage = apiErrorMessage(error) }
    }

    // MARK: - Prepaid Card (بطاقة شحن)
    // PATCH /api/v1/PrepaidCards/use-prepaid-card  body: { CardNumber }
    // Returns: String message
    func usePrepaidCard(cardNumber: String) async {
        prepaidIsLoading = true
        defer { prepaidIsLoading = false }
        struct Body: Encodable { let CardNumber: String }
        do {
            let body = try JSONEncoder().encode(Body(CardNumber: cardNumber))
            let (data, response) = try await makeClient().postRaw(
                to: "/api/v1/PrepaidCards/use-prepaid-card",
                body: body,
                contentType: "application/json",
                method: "PATCH"
            )
            try assertSuccess(data: data, response: response)
            successMessage = "تم شحن المحفظة بنجاح ✓"
            await fetchAll()
        } catch { errorMessage = apiErrorMessage(error) }
    }

    // MARK: - Masarat (بطاقة ماصرات)
    // POST /api/v1/WalletCharge/charge/initiate
    // body: { WalletId, IdentityCard, Amount, Currency, Description }
    // Returns: { transactionId: String }
    func masaratInitiate(identityCard: String, amount: Double) async {
        guard let walletId = wallet?.walletId else { errorMessage = "المحفظة غير متاحة"; return }
        masaratIsLoading = true
        defer { masaratIsLoading = false }
        struct Body: Encodable {
            let WalletId: String; let IdentityCard: String
            let Amount: Double; let Currency: String; let Description: String
        }
        struct Resp: Decodable { let transactionId: String }
        do {
            let body = try JSONEncoder().encode(Body(
                WalletId: walletId, IdentityCard: identityCard,
                Amount: amount, Currency: "LYD", Description: "شحن محفظة"
            ))
            let (data, response) = try await makeClient().postRaw(
                to: "/api/v1/WalletCharge/charge/initiate", body: body, contentType: "application/json"
            )
            try assertSuccess(data: data, response: response)
            masaratTransactionId = try JSONDecoder().decode(Resp.self, from: data).transactionId
        } catch { errorMessage = apiErrorMessage(error) }
    }

    // POST /api/v1/WalletCharge/charge/confirm
    // body: { WalletId, TransactionId, Otp, Amount, Currency, Description }
    func masaratConfirm(otp: String, amount: Double) async {
        guard let walletId = wallet?.walletId, let txId = masaratTransactionId else { return }
        masaratIsLoading = true
        defer { masaratIsLoading = false }
        struct Body: Encodable {
            let WalletId: String; let TransactionId: String; let Otp: String
            let Amount: Double; let Currency: String; let Description: String
        }
        do {
            let body = try JSONEncoder().encode(Body(
                WalletId: walletId, TransactionId: txId, Otp: otp,
                Amount: amount, Currency: "LYD", Description: "شحن محفظة"
            ))
            let (data, response) = try await makeClient().postRaw(
                to: "/api/v1/WalletCharge/charge/confirm", body: body, contentType: "application/json"
            )
            try assertSuccess(data: data, response: response)
            masaratTransactionId = nil
            successMessage = "تم شحن المحفظة عبر ماصرات بنجاح ✓"
            await fetchAll()
        } catch { errorMessage = apiErrorMessage(error) }
    }

    // MARK: - Helpers

    private func assertSuccess(data: Data, response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else {
            struct ErrBody: Decodable { let error: String?; let message: String? }
            let msg = (try? JSONDecoder().decode(ErrBody.self, from: data))?.message
                ?? (try? JSONDecoder().decode(ErrBody.self, from: data))?.error
                ?? String(data: data, encoding: .utf8)
                ?? "خطأ غير معروف"
            throw APIError.badRequest(msg)
        }
    }

    private func apiErrorMessage(_ error: Error) -> String {
        if case APIError.badRequest(let msg) = error { return msg }
        if let urlErr = error as? URLError, urlErr.code == .notConnectedToInternet {
            return "لا يوجد اتصال بالإنترنت"
        }
        return "فشل الاتصال بالخادم"
    }
}
