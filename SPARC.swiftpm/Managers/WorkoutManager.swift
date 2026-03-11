import Foundation
import SwiftUI

@MainActor
class WorkoutManager: ObservableObject {
    static let shared = WorkoutManager()
    @Published var workouts: [Workout] = []
    
    private let key = "sparc_workouts"
    
    init() {
        load()
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
            workouts = decoded
        }
    }
    
    func addWorkout(type: String, duration: Int, intensity: Int, notes: String, date: Date = Date()) {
        let newWorkout = Workout(
            type: type,
            durationMinutes: duration,
            intensity: intensity,
            notes: notes,
            date: date
        )
        withAnimation {
            workouts.insert(newWorkout, at: 0)
        }
        save()
    }
    
    // MARK: - Analytics
    
    var currentStreak: Int {
        let calendar = Calendar.current
        let uniqueDays = Set(workouts.map {
            calendar.startOfDay(for: $0.date)
        }).sorted(by: >)
        
        guard !uniqueDays.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        for day in uniqueDays {
            if calendar.isDate(day, inSameDayAs: currentDate) {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            } else if streak == 0 && calendar.startOfDay(for: day) == calendar.date(byAdding: .day, value: -1, to: currentDate) {
                // Allows the user to still have a streak if they haven't logged *yet* today
                streak += 1
                currentDate = day
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            } else {
                break
            }
        }
        
        return streak
    }
    
    var weeklyVolumeThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return workouts.filter { $0.date >= weekAgo }.reduce(0) { $0 + $1.durationMinutes }
    }
    
    var weeklyVolumeLastWeek: Int {
        let calendar = Calendar.current
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return workouts.filter { $0.date >= twoWeeksAgo && $0.date < weekAgo }.reduce(0) { $0 + $1.durationMinutes }
    }
}
