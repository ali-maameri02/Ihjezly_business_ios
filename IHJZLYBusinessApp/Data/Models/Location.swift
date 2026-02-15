// Data/Models/Location.swift

import Foundation
struct Location: Codable, Identifiable {
    let id: String
    let city: String
    let state: String
    let country: String
    
}
