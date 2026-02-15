// Data/Models/User.swift

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let fullName: String
    let phoneNumber: String
    let email: String?
    let role: String
    let isVerified: Bool
    let profilePictureUrl: String?
    
    // ❌ REMOVE THIS — it causes "Invalid redeclaration of 'id'"
    // var id: String { self.id }
    
    var displayName: String {
        return fullName
    }
    
    var displayRole: String {
        switch role {
        case "BusinessOwner": return "أعمال"
        case "Client": return "عميل"
        case "Admin": return "مسؤول"
        default: return "مستخدم"
        }
    }
}
