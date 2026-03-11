//
//  Reflection.swift
//  SPARC
//
//  Created by Anshika Thakur on 25/02/26.
//

import Foundation

struct Reflection: Identifiable, Codable {
    var id = UUID()
    let text: String
    let date: Date
    var mood: String {
        let positive = ["great", "strong", "fast", "good", "amazing", "energy", "PR", "win", "happy", "focused", "crushed"]
        let negative = ["tired", "sore", "weak", "bad", "slow", "pain", "struggle", "fatigue", "heavy", "exhausted", "lost"]
        
        let lower = text.lowercased()
        let posCount = positive.filter { lower.contains($0) }.count
        let negCount = negative.filter { lower.contains($0) }.count
        
        if posCount > negCount {
            return "Positive 🟢"
        } else if negCount > posCount {
            return "Struggling 🔴"
        } else {
            return "Neutral ⚪️"
        }
    }
}
