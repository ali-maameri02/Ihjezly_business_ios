
final class LoginUseCase {
    private let authRepo: AuthRepositoryProtocol
    
    init(authRepo: AuthRepositoryProtocol) {
        self.authRepo = authRepo
    }
    
    // LoginUseCase.swift
    func execute(emailOrPhone: String, password: String) async throws -> String {
        return try await authRepo.login(emailOrPhone: emailOrPhone, password: password)
    }

    
}



