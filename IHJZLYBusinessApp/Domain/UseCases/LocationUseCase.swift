// Domain/UseCases/LocationUseCase.swift

import Foundation

final class LocationUseCase {
    private let apiClient: APIClient
    
    init(apiClient: APIClient, token: String?) {
        self.apiClient = apiClient
        if let t = token, !t.isEmpty {
            apiClient.defaultHeaders["Authorization"] = "Bearer \(t)"
            print("🔐 Token set: \(t.prefix(10))...")
        } else {
            print("⚠️ No token found — API will fail")
        }
    }
    
    func getAllLocations() async throws -> [Location] {
        return try await apiClient.get(to: "/api/v1/Locations")
    }
}
