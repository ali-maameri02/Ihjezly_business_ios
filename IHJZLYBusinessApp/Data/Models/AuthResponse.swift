// Data/Models/AuthResponse.swift

import Foundation

// Login endpoint returns { accessToken }
struct AuthResponse: Codable {
    let accessToken: String
}

// Register endpoint returns a UserDto (no token)
struct RegisterResponse: Codable {
    let id: String
    let fullName: String
    let phoneNumber: String?
    let email: String?
    let role: String
    let isVerified: Bool
    let isBlocked: Bool
}
