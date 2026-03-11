//
//  AthleteSimulationEngine.swift
//  SPARC
//
//  Created by Anshika Thakur on 27/02/26.
//

import Foundation

struct SimulatedAthleteStats {
    let steps: Int
    let activeCalories: Int
    let trainingIntensity: Int
    let recoveryScore: Int
    let readinessScore: Double
}

class AthleteSimulationEngine {
    
    static func generateStats(
        reflectionsCount: Int,
        workouts: [Workout],
        currentStreak: Int,
        milestones: Int
    ) -> SimulatedAthleteStats {
        
        let todayWorkouts = workouts.filter { Calendar.current.isDateInToday($0.date) }
        let totalWorkoutDuration = todayWorkouts.reduce(0) { $0 + $1.durationMinutes }
        let maxWorkoutIntensity = todayWorkouts.map { $0.intensity }.max() ?? 0
        
        // Onboarding Baseline Influence
        var baseSteps = 6000
        var baseCalories = 350
        var baselineIntensity = 40
        
        if let data = UserDefaults.standard.data(forKey: "sparc_assessment"),
           let assessment = try? JSONDecoder().decode(AthleteAssessment.self, from: data) {
            if assessment.trainingDays.contains("3-4") {
                baseSteps += 2000
                baseCalories += 100
            } else if assessment.trainingDays.contains("5") || assessment.trainingDays.contains("Every") {
                baseSteps += 4000
                baseCalories += 250
                baselineIntensity += 15
            }
            if assessment.primaryGoal.contains("Endurance") {
                baseSteps += 3000
            }
        }
        
        // Boost based on streak & consistency & workouts
        let streakBoost = currentStreak * 250
        let reflectionBoost = reflectionsCount * 120
        let milestoneBoost = milestones * 400
        let workoutStepBoost = totalWorkoutDuration * 80
        let workoutCalorieBoost = totalWorkoutDuration * 8
        
        let steps = min(baseSteps + streakBoost + reflectionBoost + workoutStepBoost, 20000)
        let calories = min(baseCalories + streakBoost / 4 + milestoneBoost / 5 + workoutCalorieBoost, 1500)
        
        // Training intensity 1–100
        let intensity = min(baselineIntensity + currentStreak * 3 + milestones * 5 + (maxWorkoutIntensity * 4), 100)
        
        // Recovery (inverse logic — higher intensity lowers recovery, but over time streak increases base recovery)
        let baseRecovery = 60 + (currentStreak * 2) + (milestones * 4)
        let activeRecoveryHit = todayWorkouts.reduce(0) { $0 + ($1.intensity * 2) }
        let recovery = max(min(baseRecovery - activeRecoveryHit, 100), 20)
        
        // Readiness 0–1
        let readiness = min(Double(intensity + recovery) / 200.0, 1.0)
        
        return SimulatedAthleteStats(
            steps: steps,
            activeCalories: calories,
            trainingIntensity: intensity,
            recoveryScore: recovery,
            readinessScore: readiness
        )
    }
}
