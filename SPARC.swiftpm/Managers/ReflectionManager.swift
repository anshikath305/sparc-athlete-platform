//
//  ReflectionManager.swift
//  SPARC
//
//  Created by Anshika Thakur on 25/02/26.
//

import Foundation

@MainActor
class ReflectionManager: ObservableObject {
    static let shared = ReflectionManager()
    
    @Published var reflections: [Reflection] = []
    private let key = "sparc_reflections"
    
    init() {
        load()
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(reflections) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Reflection].self, from: data) {
            reflections = decoded
        }
    }
    
    func addReflection(text: String) {
        let newReflection = Reflection(text: text, date: Date())
        reflections.insert(newReflection, at: 0)
        save()
    }
    // MARK: - Analytics

    var currentStreak: Int {
        let calendar = Calendar.current
        let uniqueDays = Set(reflections.map {
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
            } else {
                break
            }
        }
        
        return streak
    }

    var longestStreak: Int {
        let calendar = Calendar.current
        let uniqueDays = Set(reflections.map {
            calendar.startOfDay(for: $0.date)
        }).sorted()
        
        var longest = 0
        var current = 0
        
        for i in 0..<uniqueDays.count {
            if i == 0 {
                current = 1
            } else {
                let prev = uniqueDays[i - 1]
                let curr = uniqueDays[i]
                
                if calendar.date(byAdding: .day, value: 1, to: prev) == curr {
                    current += 1
                } else {
                    longest = max(longest, current)
                    current = 1
                }
            }
        }
        
        return max(longest, current)
    }

    var reflectionsThisWeek: Int {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        return reflections.filter {
            $0.date >= weekStart
        }.count
    }
    
    // MARK: - Weekly Breakdown

    func weeklyReflectionCounts() -> [Int] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else {
            return Array(repeating: 0, count: 7)
        }
        
        var counts = Array(repeating: 0, count: 7)
        
        for reflection in reflections {
            if weekInterval.contains(reflection.date) {
                let weekday = calendar.component(.weekday, from: reflection.date)
                
                // Convert Sunday-based index to 0-based array index
                let index = (weekday + 5) % 7
                counts[index] += 1
            }
        }
        
        return counts
    }
    
    
}

