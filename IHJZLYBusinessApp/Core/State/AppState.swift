// Core/State/AppState.swift
import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    
    init() {
        // Check if user is logged in on launch
        isAuthenticated = UserDefaults.standard.string(forKey: "auth_token") != nil
    }
}
