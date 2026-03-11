//
//  Color+SPARC.swift
//  SPARC
//
//  Created by Anshika Thakur on 24/02/26.
//
import SwiftUI

extension Color {
    
    // Background Colors
    static let sparcBackground = Color(hex: "#0B0F14")
    static let sparcCard = Color(hex: "#121822")
    
    // Neon Accents
    static let sparcCyan = Color(hex: "#00F0FF")
    static let sparcViolet = Color(hex: "#7A5CFF")
    static let sparcGold = Color(hex: "#FFC857")
}

// MARK: - Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255,
                           (int >> 8) * 17,
                           (int >> 4 & 0xF) * 17,
                           (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                           int >> 16,
                           int >> 8 & 0xFF,
                           int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24,
                           int >> 16 & 0xFF,
                           int >> 8 & 0xFF,
                           int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

