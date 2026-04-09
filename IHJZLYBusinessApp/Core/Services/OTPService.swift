// Core/Services/OTPService.swift

import Foundation

// MARK: - OTP Error
enum OTPError: LocalizedError {
    case invalidPhone
    case invalidOTP
    case networkError(Error)
    case serverError(Int, String?)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidPhone:           return "رقم الهاتف غير صحيح"
        case .invalidOTP:             return "رمز التحقق غير صحيح"
        case .networkError(let e):    return e.localizedDescription
        case .serverError(_, let m):  return m ?? "حدث خطأ في الخادم"
        case .decodingError:          return "خطأ في معالجة البيانات"
        }
    }
}

// MARK: - Request model
struct OTPRequest: Encodable {
    /// Full international phone number e.g. "218912345678"
    let phone: String
}

// MARK: - Response model
struct OTPResponse: Decodable {
    let id: String
    let pin: String       // Actual OTP code returned in test mode
    let code: String      // Country code e.g. "218"
    let region: String    // e.g. "LY"
    let number: String    // Local number without country code
    let content: String   // SMS message text

    enum CodingKeys: String, CodingKey {
        case id, pin, code, region, number, content
    }
}

// MARK: - Validation error shape from Resala API
private struct ResalaValidationError: Decodable {
    let message: String?
    let errors: [String: [String]]?
}

// MARK: - OTP Service
/// Handles all communication with the Resala OTP API.
/// Completely isolated from the app's APIClient — uses its own URLSession.
final class OTPService {

    static let shared = OTPService()
    private init() {}

    // Confirmed working base URL (JWT iss = https://dev.resala.ly)
    private let baseURL = "https://dev.resala.ly/api/v1"

    // API key stored as a private constant — never exposed to the UI layer
    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2Rldi5yZXNhbGEubHkiLCJzdWIiOiI1NDBiZDkyYS01MDVhLTQwMzYtOGVkNy1iNmRhNTJkMzQ5MTAiLCJpYXQiOjE3NTY4MDkzMzUsImp0aSI6IjAyOGE3MjA2LWQzZjItNGEwZi1hNWIwLTJlZmY2YmE3YjM1ZCJ9.ui6ukgLtqhYqyLN6Oj4anshx1U2-pYHYmg6igbXXvnI"

    private let serviceName = "ihjezly"
    private let session = URLSession.shared

    // MARK: - Send OTP
    /// Sends an OTP to the given phone number.
    /// - Parameter phone: Full international number e.g. "218912345678"
    func sendOTP(phone: String) async throws -> OTPResponse {
        guard !phone.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw OTPError.invalidPhone
        }

        var components = URLComponents(string: "\(baseURL)/pins")!
        components.queryItems = [
            URLQueryItem(name: "test", value: "test"),
            URLQueryItem(name: "service_name", value: serviceName)
        ]
        guard let url = components.url else { throw OTPError.invalidPhone }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(OTPRequest(phone: phone))

        return try await perform(request)
    }

    // MARK: - Resend OTP
    func resendOTP(phone: String) async throws -> OTPResponse {
        try await sendOTP(phone: phone)
    }

    // MARK: - Verify OTP (client-side comparison)
    /// In test mode the API returns the actual pin — compare locally.
    func verifyOTP(entered: String, expected: OTPResponse) throws {
        let trimmed = entered.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { throw OTPError.invalidOTP }
        guard trimmed == expected.pin else { throw OTPError.invalidOTP }
    }

    // MARK: - Private request executor
    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw OTPError.serverError(0, nil)
            }
            switch http.statusCode {
            case 200...299:
                do { return try JSONDecoder().decode(T.self, from: data) }
                catch { throw OTPError.decodingError }
            case 422:
                let body = try? JSONDecoder().decode(ResalaValidationError.self, from: data)
                let msg = body?.message
                    ?? body?.errors?.values.first?.first
                    ?? "خطأ في البيانات المدخلة"
                throw OTPError.serverError(422, msg)
            default:
                let body = try? JSONDecoder().decode(ResalaValidationError.self, from: data)
                throw OTPError.serverError(http.statusCode, body?.message)
            }
        } catch let e as OTPError { throw e }
        catch { throw OTPError.networkError(error) }
    }
}
