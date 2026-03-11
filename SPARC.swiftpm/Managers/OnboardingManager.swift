import Foundation

struct AthleteAssessment: Codable {
    var primaryGoal: String = ""
    var trainingDays: String = ""
    var trainingType: String = ""
    var consistency: String = ""
    var mentalResilience: String = ""
    var biggestChallenge: String = ""
    var motivation: String = ""
    var trainingTime: String = ""
    var recoveryImportance: String = ""
    var successDefinition: String = ""
    
    var isCompleted: Bool {
        !primaryGoal.isEmpty && !trainingDays.isEmpty && !trainingType.isEmpty && !consistency.isEmpty && !mentalResilience.isEmpty && !biggestChallenge.isEmpty && !motivation.isEmpty && !trainingTime.isEmpty && !recoveryImportance.isEmpty && !successDefinition.isEmpty
    }
}

@MainActor
class OnboardingManager: ObservableObject {
    @Published var assessment: AthleteAssessment
    @Published var hasCompletedOnboarding: Bool = false
    
    private let key = "sparc_assessment"
    private let completedKey = "sparc_onboarding_completed"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(AthleteAssessment.self, from: data) {
            self.assessment = decoded
        } else {
            self.assessment = AthleteAssessment()
        }
        
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: completedKey)
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(assessment) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func completeOnboarding() {
        save()
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: completedKey)
    }
}
