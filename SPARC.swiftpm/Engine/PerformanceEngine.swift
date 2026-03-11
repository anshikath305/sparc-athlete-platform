//
//  PerformanceEngine.swift
//  SPARC
//
//  Created by Anshika Thakur on 27/02/26.
//

import Foundation

struct PerformanceInsights {
    let score: Int
    let resilienceIndex: Int
    let tier: String
    let weeklyGrowth: Int
    let momentumText: String
    let bestDay: String
    let insightText: String
}

class PerformanceEngine {
    
    static func generateInsights(
        reflections: [Reflection],
        workouts: [Workout],
        milestonesCount: Int,
        currentStreak: Int
    ) -> PerformanceInsights {
        
        let calendar = Calendar.current
        
        // Weekly Data
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        
        let reflectionsThisWeek = reflections.filter { $0.date >= weekAgo }.count
        let reflectionsLastWeek = reflections.filter { $0.date >= twoWeeksAgo && $0.date < weekAgo }.count
        
        let workoutsThisWeek = workouts.filter { $0.date >= weekAgo }.count
        let workoutsLastWeek = workouts.filter { $0.date >= twoWeeksAgo && $0.date < weekAgo }.count
        
        // Best day detection (from combined activity)
        let weekdaySymbols = calendar.shortWeekdaySymbols
        var weekdayCount: [Int: Int] = [:]
        
        for item in (reflections.map { $0.date } + workouts.map { $0.date }) {
            let weekday = calendar.component(.weekday, from: item)
            weekdayCount[weekday, default: 0] += 1
        }
        
        let bestWeekdayIndex = weekdayCount.max(by: { $0.value < $1.value })?.key ?? 1
        let bestDay = weekdaySymbols[bestWeekdayIndex - 1]
        
        // Weekly growth %
        let totalThisWeek = reflectionsThisWeek + workoutsThisWeek
        let totalLastWeek = reflectionsLastWeek + workoutsLastWeek
        
        let weeklyGrowth = totalLastWeek == 0
            ? totalThisWeek * 10
            : Int(((Double(totalThisWeek - totalLastWeek) / Double(totalLastWeek)) * 100))
        
        // Performance Score Calculation
        let streakScore = min(currentStreak * 2, 30) // max 30
        let consistencyScore = min(totalThisWeek * 5, 30) // max 30
        let milestoneScore = min(milestonesCount * 5, 20) // max 20
        let workoutScore = min(workoutsThisWeek * 5, 20) // max 20
        
        let totalScore = min(streakScore + consistencyScore + milestoneScore + workoutScore, 100)
        
        // Resilience Index (mental toughness)
        let resilienceIndex = min(50 + (reflectionsThisWeek * 5) + (workoutsThisWeek * 2) + (currentStreak * 2), 100)
        
        // Tier
        let tier: String
        switch totalScore {
        case 85...100: tier = "Peak"
        case 60..<85: tier = "Momentum"
        case 30..<60: tier = "Foundation"
        default: tier = "Building"
        }
        
        // Momentum Tracking
        let momentumText: String
        if currentStreak >= 5 || weeklyGrowth > 15 {
            momentumText = "High Momentum 🔥"
        } else if currentStreak >= 2 || totalThisWeek >= 2 {
            momentumText = "Building Momentum 🚀"
        } else {
            momentumText = "Maintaining ⚖️"
        }
        
        // Insight Text
        let insight = generateInsightText(
            score: totalScore,
            growth: weeklyGrowth,
            resilience: resilienceIndex,
            bestDay: bestDay,
            tier: tier,
            momentum: momentumText
        )
        
        return PerformanceInsights(
            score: totalScore,
            resilienceIndex: resilienceIndex,
            tier: tier,
            weeklyGrowth: weeklyGrowth,
            momentumText: momentumText,
            bestDay: bestDay,
            insightText: insight
        )
    }
    
    private static func generateInsightText(
        score: Int,
        growth: Int,
        resilience: Int,
        bestDay: String,
        tier: String,
        momentum: String
    ) -> String {
        
        if resilience > 80 && score > 80 {
            return "Elite discipline. Your mental resilience index is \(resilience)/100. \(bestDay) is your undeniable power day. You are operating at \(tier) capacity."
        }
        
        if growth > 20 {
            return "Strong progression! Activity improved by \(growth)% this week. \(bestDay) seems to be your strongest training day. You're in \(tier) mode."
        }
        
        if score > 70 {
            return "Solid consistency across physical and mental tracking. Maintain this rhythm on \(bestDay)s to push into Peak performance."
        }
        
        return "You’re \(momentum.lowercased()). Focus on maintaining your streak and aligning your workouts and reflections."
    }
}
