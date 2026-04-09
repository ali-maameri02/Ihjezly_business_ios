// Core/State/AppState.swift
import Foundation
import Combine

final class AppState: ObservableObject {

    @Published var isAuthenticated = false
    @Published var isValidatingToken = true   // shows a splash while we check

    private let tokenKey = "auth_token"

    init() {
        let stored = UserDefaults.standard.string(forKey: tokenKey) ?? ""
        if stored.isEmpty {
            // No token at all — go straight to auth
            isAuthenticated = false
            isValidatingToken = false
        } else {
            // Token exists — validate it against the backend before trusting it
            Task { await validateToken() }
        }
    }

    // MARK: - Validate stored token
    /// Calls GET /api/v1/Users/me with the stored token.
    /// If the server accepts it → isAuthenticated = true.
    /// If 401 / any error → clear the token and show auth flow.
    @MainActor
    private func validateToken() async {
        guard let token = UserDefaults.standard.string(forKey: tokenKey),
              !token.isEmpty else {
            isAuthenticated = false
            isValidatingToken = false
            return
        }

        let client = APIClient(baseURLString: "http://31.220.56.155:5050")
        client.defaultHeaders["Authorization"] = "Bearer \(token)"

        do {
            let _: User = try await client.get(to: "/api/v1/Users/me")
            isAuthenticated = true
        } catch {
            // Token expired or invalid — force the user back to login
            UserDefaults.standard.removeObject(forKey: tokenKey)
            isAuthenticated = false
        }
        isValidatingToken = false
    }

    // MARK: - Logout
    func logout() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        isAuthenticated = false
    }
}
