import SwiftUI

struct LibraryItem: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let description: String
    let icon: String
    let color: Color
}

struct HealthLibraryView: View {
    
    let items = [
        LibraryItem(title: "Hydration Strategy", category: "Recovery", description: "Optimize performance by maintaining fluid balance. Aim for 3L daily for high intensity training.", icon: "drop.fill", color: .blue),
        LibraryItem(title: "Sleep & Recovery", category: "Mindset", description: "Deep sleep phases are where mental resilience and physical repair happen. Don't skip the 8 hours.", icon: "moon.zzz.fill", color: .indigo),
        LibraryItem(title: "Macro-Nutrient Balance", category: "Diet", description: "Carbs fuel, Protein repairs, Fats regulate. Find the ratio that works for your sport archetype.", icon: "fork.knife", color: .orange),
        LibraryItem(title: "Active Recovery", category: "Training", description: "Low-intensity movement on rest days keeps the blood flowing and reduces DOMS significantly.", icon: "figure.walk", color: .green),
        LibraryItem(title: "Breathing Patterns", category: "Mindset", description: "Box breathing before a session can lower cortisol and sharpen your focus for peak performance.", icon: "wind", color: .sparcCyan),
        LibraryItem(title: "Consistency vs Intensity", category: "Performance", description: "Small efforts over time beat massive sporadic bursts. Build the habit before the intensity.", icon: "chart.line.uptrend.xyaxis", color: .sparcViolet)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Health & Performance Library")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(items) { item in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: item.icon)
                                    .font(.title2)
                                    .foregroundColor(item.color)
                                Spacer()
                                Text(item.category)
                                    .font(.caption2.bold())
                                    .foregroundColor(item.color)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(item.color.opacity(0.1))
                                    .cornerRadius(6)
                            }
                            
                            Text(item.title)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(item.description)
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .lineLimit(3)
                        }
                        .padding(16)
                        .frame(width: 200, height: 160)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.sparcCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(item.color.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
