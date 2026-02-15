// Data/Repositories/AuthRepository.swift

import Foundation

final class AuthRepository: AuthRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func requestOTP(phoneNumber: String) async throws {
        let normalized = normalizePhoneNumber(phoneNumber)
        let request = PhoneVerificationRequest(phoneNumber: normalized)
        _ = try await apiClient.post(
            to: "/api/v1/Users/verify-phone",
            body: request
        ) as EmptyResponse
    }
    
    func register(fullName: String, phoneNumber: String, email: String, password: String, role: UserRole) async throws -> String {
        let normalizedPhone = normalizePhoneNumber(phoneNumber)
        let request = RegisterRequest(
            fullName: fullName,
            phoneNumber: normalizedPhone,
            email: email,
            password: password,
            role: role
        )
        let response: AuthResponse = try await apiClient.post(
            to: "/api/v1/Users/register",
            body: request
        )
        return response.accessToken
    }
    
    func login(emailOrPhone: String, password: String) async throws -> String {
        let request = LoginRequest(emailOrPhone: emailOrPhone, password: password)
        let response: AuthResponse = try await apiClient.post(
            to: "/api/v1/Users/login",
            body: request
        )
        return response.accessToken
    }
    
    
    func fetchCurrentUser() async throws -> User {
         let response: User = try await apiClient.get(to: "/api/v1/Users/me")
         return response
     }
    // MARK: - Helpers
    
    private func normalizePhoneNumber(_ input: String) -> String {
        let digits = input.filter { $0.isNumber }
        if digits.hasPrefix("218") && digits.count == 12 {
            return digits
        } else if digits.count == 9 {
            return "218" + digits
        } else {
            // Fallback: assume user entered full 12-digit without +
            return String(digits.prefix(12))
        }
    }
    
    private func normalizeLoginInput(_ input: String) -> String {
        if input.contains("@") {
            return input // Email
        } else {
            return normalizePhoneNumber(input) // Phone
        }
    }
}
