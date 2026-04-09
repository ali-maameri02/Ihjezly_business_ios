// Domain/Repositories/AuthRepositoryProtocol.swift

import Foundation

protocol AuthRepositoryProtocol {
    func requestOTP(phoneNumber: String) async throws
    func register(fullName: String, phoneNumber: String, email: String, password: String, role: UserRole) async throws -> RegisterResponse
    func login(emailOrPhone: String, password: String) async throws -> String
    func fetchCurrentUser() async throws -> User
}
