// Domain/UseCases/RequestOTPUseCase.swift

import Foundation

final class RequestOTPUseCase {
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol = Container.shared.resolve(AuthRepositoryProtocol.self)) {
        self.authRepository = authRepository
    }
    
    func execute(phoneNumber: String) async throws {
        try await authRepository.requestOTP(phoneNumber: phoneNumber)
    }
}
