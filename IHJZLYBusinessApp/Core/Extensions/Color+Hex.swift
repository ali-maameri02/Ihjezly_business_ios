// Core/Extensions/Color+Hex.swift

import SwiftUI

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized = String(hexSanitized.dropFirst())
        }
        
        guard hexSanitized.count == 6 else { return nil }
        
        let scanner = Scanner(string: hexSanitized)
        var rgbValue: UInt64 = 0
        
        guard scanner.scanHexInt64(&rgbValue) else { return nil }
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self = Color(red: r, green: g, blue: b)
    }
}
