// Data/Models/Property.swift

// Data/Models/Property.swift

import Foundation

struct Property: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let price: Double?
    let currency: String
    let type: String           // "Residence" or "Hall"
    let rawSubtype: String     // e.g., "Apartment"
    let images: [ImageItem]?
    let status: String?
    let businessOwnerFullName: String
    
   
}

struct ImageItem: Codable {
    let url: String
}

enum PropertyStatus: String, Codable {
    case pending = "Pending"
    case accepted = "Accepted"
    case refused = "Refused"
}
