// Domain/UseCases/RegisterUseCase.swift

import Foundation

final class RegisterUseCase {
    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol = Container.shared.resolve(AuthRepositoryProtocol.self)) {
        self.authRepository = authRepository
    }

    func execute(
        fullName: String,
        phoneNumber: String,
        email: String,
        password: String,
        role: UserRole
    ) async throws -> RegisterResponse {
        return try await authRepository.register(
            fullName: fullName,
            phoneNumber: phoneNumber,
            email: email,
            password: password,
            role: role
        )
    }
}
