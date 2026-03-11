import SwiftUI

struct QuizView: View {
    
    @StateObject private var manager = OnboardingManager()
    
    @State private var showResult = false
    @State private var currentStep = 0
    
    @State private var answers: [String?] = Array(repeating: nil, count: 10)
    
    let questions = [
        ("What is your primary goal?", ["Strength & Power", "Endurance & Stamina", "Balance & Recovery", "Mental Discipline"]),
        ("How many days per week do you train?", ["1-2 Days", "3-4 Days", "5-6 Days", "Every Day"]),
        ("What type of training do you focus on?", ["Weightlifting", "Cardio / Runners", "Hybrid / Cross-Train", "Mobility / Yoga"]),
        ("How consistent do you feel currently?", ["Inconsistent", "On & Off", "Mostly Consistent", "Unbreakable"]),
        ("How would you rate your mental resilience?", ["Struggle Under Pressure", "I Push Through", "Balanced", "Thrive Under Pressure"]),
        ("What is your biggest challenge?", ["Finding Time", "Refueling & Diet", "Recovery / Sleep", "Staying Focused"]),
        ("What motivates you most?", ["Personal Records", "Health & Longevity", "Competition", "Mental Clarity"]),
        ("When do you usually train?", ["Early Morning", "Lunch Break", "Evening", "Late Night"]),
        ("How important is recovery to you?", ["I often skip it", "I recover sometimes", "Very Important", "My top priority"]),
        ("What does success look like for you?", ["Hitting New Levels", "Feeling Invincible", "Longevity", "Unshakeable Mind"])
    ]
    
    var body: some View {
        ZStack {
            Color.sparcBackground
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                // Progress Bar
                ProgressView(value: Double(currentStep + 1), total: 10.0)
                    .tint(.sparcCyan)
                    .padding(.horizontal)
                
                Spacer()
                
                Group {
                    QuestionView(
                        title: questions[currentStep].0,
                        options: questions[currentStep].1,
                        selection: Binding(
                            get: { answers[currentStep] },
                            set: { answers[currentStep] = $0 }
                        )
                    )
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                    .id(currentStep)
                }
                
                Spacer()
                
                Button {
                    nextStep()
                } label: {
                    Text(currentStep == 9 ? "Calculate Profile" : "Continue")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.sparcCyan, .sparcViolet],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    .cornerRadius(16)
                    .shadow(color: .sparcCyan.opacity(0.5), radius: 10)
                }
                .padding(.horizontal)
                .disabled(answers[currentStep] == nil)
                .opacity(answers[currentStep] != nil ? 1 : 0.5)
                
                Spacer()
            }
            .padding()
        }
        .navigationDestination(isPresented: $showResult) {
            QuizResultView(manager: manager)
        }
    }
    
    // MARK: - Logic
    
    func nextStep() {
        if currentStep < 9 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                currentStep += 1
            }
        } else {
            finalizeOnboarding()
        }
    }
    
    private func finalizeOnboarding() {
        manager.assessment.primaryGoal = answers[0] ?? ""
        manager.assessment.trainingDays = answers[1] ?? ""
        manager.assessment.trainingType = answers[2] ?? ""
        manager.assessment.consistency = answers[3] ?? ""
        manager.assessment.mentalResilience = answers[4] ?? ""
        manager.assessment.biggestChallenge = answers[5] ?? ""
        manager.assessment.motivation = answers[6] ?? ""
        manager.assessment.trainingTime = answers[7] ?? ""
        manager.assessment.recoveryImportance = answers[8] ?? ""
        manager.assessment.successDefinition = answers[9] ?? ""
        
        manager.completeOnboarding()
        showResult = true
    }
}
