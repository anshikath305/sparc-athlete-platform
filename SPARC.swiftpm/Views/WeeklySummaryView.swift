import SwiftUI

struct WeeklySummaryView: View {
    let insights: PerformanceInsights
    let weeklyVolumeThisWeek: Int
    let reflectionStreak: Int
    
    @Environment(\.dismiss) var dismiss
    
    @State private var appear = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            
            VStack(spacing: 32) {
                
                // Badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.sparcCyan, .sparcViolet],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: .sparcCyan.opacity(0.8), radius: appear ? 30 : 5)
                    
                    VStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 32))
                        Text(insights.tier)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.black)
                }
                .scaleEffect(appear ? 1.0 : 0.6)
                .opacity(appear ? 1.0 : 0)
                
                // Title
                VStack(spacing: 8) {
                    Text("Weekly Performance Report")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(insights.insightText)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .opacity(appear ? 1.0 : 0)
                .offset(y: appear ? 0 : 20)
                
                // Stats Grid
                HStack(spacing: 16) {
                    statBox(title: "Active Mins", value: "\(weeklyVolumeThisWeek)", icon: "timer")
                    statBox(title: "Mental Index", value: "\(insights.resilienceIndex)", icon: "brain")
                }
                .padding(.horizontal)
                .opacity(appear ? 1.0 : 0)
                .offset(y: appear ? 0 : 30)
                
                HStack(spacing: 16) {
                    statBox(title: "Current Streak", value: "\(reflectionStreak)", icon: "flame")
                    statBox(title: "Weekly Growth", value: "+\(insights.weeklyGrowth)%", icon: "arrow.up.right")
                }
                .padding(.horizontal)
                .opacity(appear ? 1.0 : 0)
                .offset(y: appear ? 0 : 40)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.gray.opacity(0.5))
                    .padding()
            }
            .padding(.vertical, 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                appear = true
                triggerHapticFeedback(.rigid)
            }
        }
    }
    
    private func statBox(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.sparcCyan)
                .font(.system(size: 20))
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.sparcCard))
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}
