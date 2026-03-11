import SwiftUI

struct AddWorkoutView: View {
    @ObservedObject var manager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    
    @State private var type: String = "Strength"
    @State private var duration: Double = 45
    @State private var intensity: Double = 6
    @State private var notes: String = ""
    
    let types = ["Strength", "Cardio", "Mobility", "Recovery", "Sport Specific"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sparcBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Workout Type")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(types, id: \.self) { workoutType in
                                        Button {
                                            withAnimation(.spring()) {
                                                type = workoutType
                                                triggerHapticFeedback(.light)
                                            }
                                        } label: {
                                            Text(workoutType)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(type == workoutType ? Color.sparcCyan : Color.sparcCard)
                                                )
                                                .foregroundColor(type == workoutType ? .black : .gray)
                                        }
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Duration")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(duration)) min")
                                    .foregroundColor(.sparcCyan)
                                    .bold()
                            }
                            
                            Slider(value: $duration, in: 5...180, step: 5)
                                .tint(.sparcCyan)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.sparcCard))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Intensity")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(intensity))/10")
                                    .foregroundColor(.sparcViolet)
                                    .bold()
                            }
                            
                            Slider(value: $intensity, in: 1...10, step: 1)
                                .tint(.sparcViolet)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.sparcCard))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Coach's Notes")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            TextEditor(text: $notes)
                                .frame(height: 120)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.sparcCard))
                                .foregroundColor(.white)
                        }
                        
                        Button {
                            triggerHapticFeedback(.medium)
                            manager.addWorkout(
                                type: type,
                                duration: Int(duration),
                                intensity: Int(intensity),
                                notes: notes
                            )
                            dismiss()
                        } label: {
                            Text("Log Workout")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(LinearGradient(colors: [.sparcCyan, .sparcViolet], startPoint: .leading, endPoint: .trailing))
                                )
                        }
                        .padding(.top, 16)
                        
                    }
                    .padding()
                }
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
