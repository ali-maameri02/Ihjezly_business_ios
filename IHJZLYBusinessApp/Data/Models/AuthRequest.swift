struct PhoneVerificationRequest: Codable {
    let phoneNumber: String
}

struct RegisterRequest: Codable {
    let fullName: String
    let phoneNumber: String
    let email: String
    let password: String
    let role: UserRole
}

struct LoginRequest: Codable {
    let emailOrPhone: String
    let password: String
}

enum UserRole: String, Codable {
    case client = "Client"
    case businessOwner = "BusinessOwner"
}
