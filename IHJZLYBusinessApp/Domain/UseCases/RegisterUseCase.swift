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
    ) async throws -> String {
        return try await authRepository.register( // ✅ Added "register"
            fullName: fullName,
            phoneNumber: phoneNumber,
            email: email,
            password: password,
            role: role
        )
    }
}
