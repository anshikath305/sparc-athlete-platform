import SwiftUI

struct QuizResultView: View {
    
    @ObservedObject var manager: OnboardingManager
    
    @State private var phase = 0
    @State private var goToDashboard = false
    @State private var userName = ""
    
    var body: some View {
        ZStack {
            Color.sparcBackground
                .ignoresSafeArea()
            
            // Expanding Gradient Orb
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.sparcCyan, .sparcViolet],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: phase > 0 ? 300 : 50, height: phase > 0 ? 300 : 50)
                .blur(radius: phase > 0 ? 60 : 10)
                .opacity(phase > 0 ? 0.4 : 0)
                .scaleEffect(phase > 2 ? 1.2 : 1.0)
                .animation(Animation.easeInOut(duration: 4).repeatForever(autoreverses: true), value: phase)
            
            VStack(spacing: 30) {
                
                if phase > 1 {
                    Text("Welcome to SPARC")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.gray)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    
                    Text(userName.isEmpty ? "Athlete" : userName)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.opacity.combined(with: .scale))
                    
                    Text("Your journey to balanced performance and mental resilience begins now.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
                
                if phase > 2 {
                    Button {
                        triggerHapticFeedback(.rigid)
                        withAnimation(.easeOut(duration: 0.8)) {
                            goToDashboard = true
                        }
                    } label: {
                        Text("Begin Your Journey")
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
                            .shadow(color: .sparcCyan.opacity(0.6), radius: 15)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .navigationDestination(isPresented: $goToDashboard) {
            DashboardView()
                .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            if let data = UserDefaults.standard.data(forKey: "sparc_profile"),
               let profile = try? JSONDecoder().decode(AthleteProfile.self, from: data) {
                userName = profile.name
            }
            
            withAnimation(.easeOut(duration: 1.5)) { phase = 1 }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 1.2)) { phase = 2 }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 1.0)) { phase = 3 }
                triggerHapticFeedback(.success)
            }
        }
    }
}
