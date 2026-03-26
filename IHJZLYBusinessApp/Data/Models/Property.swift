// Data/Models/Property.swift

import Foundation

struct Property: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let location: LocationDto
    let price: Double?
    let currency: String
    let discount: DiscountDto?
    let isAd: Bool
    let facilities: [FacilityDto]
    let type: String           // "Residence" or "Hall"
    let status: String?
    let viedeoUrl: ViedeoUrlDto?
    let createdAt: String
    let updatedAt: String
    let unavailables: [String] // ISO8601 date strings
    let details: AnyCodable?
    let images: [ImageItem]?
    let businessOwnerId: String
    let businessOwnerFullName: String
    let isLoved: Bool
}

struct LocationDto: Codable {
    let city: String
    let state: String
    let country: String
    let latitude: Double
    let longitude: Double
}

struct DiscountDto: Codable {
    let value: Double
}

struct FacilityDto: Codable {
    let name: String
}

struct ViedeoUrlDto: Codable {
    let url: String?
}

struct ImageItem: Codable {
    let url: String
    let isMain: Bool?
}

enum PropertyStatus: String, Codable {
    case pending = "Pending"
    case accepted = "Accepted"
    case refused = "Refused"
}

// Wrapper to decode any JSON value for the `details` field
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) { self.value = value }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) { value = int }
        else if let double = try? container.decode(Double.self) { value = double }
        else if let bool = try? container.decode(Bool.self) { value = bool }
        else if let string = try? container.decode(String.self) { value = string }
        else if let dict = try? container.decode([String: AnyCodable].self) { value = dict }
        else if let array = try? container.decode([AnyCodable].self) { value = array }
        else { value = NSNull() }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let int as Int: try container.encode(int)
        case let double as Double: try container.encode(double)
        case let bool as Bool: try container.encode(bool)
        case let string as String: try container.encode(string)
        case let dict as [String: AnyCodable]: try container.encode(dict)
        case let array as [AnyCodable]: try container.encode(array)
        default: try container.encodeNil()
        }
    }
}
