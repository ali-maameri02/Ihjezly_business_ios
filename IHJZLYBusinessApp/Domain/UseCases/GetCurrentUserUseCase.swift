// Domain/UseCases/GetCurrentUserUseCase.swift

import Foundation

final class GetCurrentUserUseCase {
    private let authRepo: AuthRepositoryProtocol
    
    init(authRepo: AuthRepositoryProtocol) {
        self.authRepo = authRepo
    }
    
    func execute() async throws -> User {
        guard let token = UserDefaults.standard.string(forKey: "auth_token") else {
            throw AuthError.unauthorized
        }
        
        // ✅ Create client with auth header
        let client = APIClient(baseURLString: "http://31.220.56.155:5050")
        client.defaultHeaders["Authorization"] = "Bearer \(token)"
        let repo = AuthRepository(apiClient: client)
        return try await repo.fetchCurrentUser()
    }
}

enum AuthError: Error {
    case unauthorized
}
