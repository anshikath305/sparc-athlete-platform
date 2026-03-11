import SwiftUI

struct PortfolioShareCard: View {
    let profile: AthleteProfile
    let archetype: String
    let stats: SimulatedAthleteStats?
    let insights: PerformanceInsights?
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name.isEmpty ? "Athlete" : profile.name)
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.white)
                    
                    Text(profile.sport.isEmpty ? "Pro Athlete" : profile.sport)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.sparcCyan)
                }
                Spacer()
                
                VStack(alignment: .center, spacing: 2) {
                    Text("SPARC")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white)
                    Text("PERFORMANCE")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.gray)
                }
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.3)))
            }
            
            // Badge
            VStack {
                Text(archetype)
                    .font(.system(size: 16, weight: .black))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(LinearGradient(colors: [.sparcCyan, .sparcViolet], startPoint: .leading, endPoint: .trailing))
                    )
                    .foregroundColor(.black)
                    .shadow(color: .sparcCyan.opacity(0.4), radius: 10)
            }
            
            // Stats Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                StatItem(label: "Readiness", value: "\(Int((stats?.readinessScore ?? 0) * 100))%", icon: "bolt.fill")
                StatItem(label: "Mental Index", value: "\(insights?.resilienceIndex ?? 0)", icon: "brain.head.profile")
                StatItem(label: "Awards", value: "\(profile.achievements.count)", icon: "trophy.fill")
                StatItem(label: "Tier", value: insights?.tier ?? "Building", icon: "crown.fill")
            }
            
            Spacer().frame(height: 10)
            
            // Footer
            Text("ELEVATING PERFORMANCE THROUGH DISCIPLINE")
                .font(.system(size: 10, weight: .black))
                .tracking(2)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(40)
        .frame(width: 400, height: 600)
        .background(
            ZStack {
                Color.sparcBackground
                
                LinearGradient(
                    colors: [.sparcCyan.opacity(0.15), .clear, .sparcViolet.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Circle()
                    .fill(Color.sparcCyan.opacity(0.1))
                    .frame(width: 300)
                    .offset(x: -150, y: -250)
                    .blur(radius: 80)
                
                Circle()
                    .fill(Color.sparcViolet.opacity(0.1))
                    .frame(width: 300)
                    .offset(x: 150, y: 250)
                    .blur(radius: 80)
            }
        )
        .edgesIgnoringSafeArea(.all)
    }
}

struct StatItem: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.sparcCyan)
                Text(label)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
            }
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
    }
}
