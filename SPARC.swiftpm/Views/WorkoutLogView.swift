import SwiftUI

struct WorkoutLogView: View {
    @ObservedObject var manager: WorkoutManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
               
                // Analytics Cards
                HStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Image(systemName: "timer")
                            .foregroundColor(.sparcCyan)
                        Text("\(manager.weeklyVolumeThisWeek) min")
                            .foregroundColor(.white)
                            .font(.headline)
                            .contentTransition(.numericText())
                            .animation(.spring(), value: manager.weeklyVolumeThisWeek)
                        Text("This Week")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.sparcCard))
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.sparcViolet)
                        
                        let diff = manager.weeklyVolumeThisWeek - manager.weeklyVolumeLastWeek
                        let symbol = diff >= 0 ? "+" : ""
                        
                        Text("\(symbol)\(diff) min")
                            .foregroundColor(diff >= 0 ? .sparcViolet : .red)
                            .font(.headline)
                            .contentTransition(.numericText())
                            .animation(.spring(), value: diff)
                        Text("Growth")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.sparcCard))
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                
                // History List
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Workout History")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if manager.workouts.isEmpty {
                        Text("No workouts logged yet. Start training!")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(manager.workouts) { workout in
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(LinearGradient(colors: [.sparcCyan, .sparcViolet], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 45, height: 45)
                                    .overlay(
                                        Image(systemName: iconForType(workout.type))
                                            .foregroundColor(.black)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.type)
                                        .foregroundColor(.white)
                                        .font(.headline)
                                    Text("\(workout.durationMinutes) min • Intensity: \(workout.intensity)/10")
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.sparcCard))
                            .padding(.horizontal)
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color.sparcBackground.ignoresSafeArea())
        .navigationTitle("Workout Log")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
        case "Strength": return "dumbbell.fill"
        case "Cardio": return "figure.run"
        case "Mobility": return "figure.yoga"
        case "Recovery": return "heart.fill"
        default: return "bolt.fill"
        }
    }
}
