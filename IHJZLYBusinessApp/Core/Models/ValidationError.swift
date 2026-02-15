// Core/Models/ValidationError.swift

import Foundation

struct ValidationError: Identifiable {
    let id = UUID()
    let message: String
}
