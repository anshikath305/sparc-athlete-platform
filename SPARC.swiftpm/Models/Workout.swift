import Foundation

struct Workout: Identifiable, Codable {
    var id = UUID()
    let type: String // "Strength", "Cardio", "Mobility", "Recovery"
    let durationMinutes: Int
    let intensity: Int // 1-10
    let notes: String
    let date: Date
}
