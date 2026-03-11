import SwiftUI

struct TimelineNodeView: View {
    let achievement: Achievement
    let isEditing: Bool
    let deleteAction: () -> Void
    
    @State private var isExpanded = false
    @State private var appear = false

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            // Node Dot & Line
            VStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.sparcCyan, .sparcViolet],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 16, height: 16)
                    .shadow(color: .sparcCyan.opacity(0.8), radius: appear ? 10 : 0)
                    .scaleEffect(appear ? 1.0 : 0.4)
                    .animation(Animation.spring(response: 0.6, dampingFraction: 0.5).repeatForever(autoreverses: true), value: appear)
                    
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.sparcCyan.opacity(0.8), .sparcViolet.opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 3)
            }
            .padding(.top, 4)
            
            // Card Content
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(achievement.title)
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                        
                        Text("Milestone Unlocked")
                            .foregroundColor(.sparcCyan)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    if isEditing {
                        Button {
                            deleteAction()
                        } label: {
                            Image(systemName: "trash.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 22))
                        }
                    } else {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        if let data = achievement.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 150)
                                .clipped()
                                .cornerRadius(12)
                                .transition(.opacity.combined(with: .scale))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Growth Impact")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray.opacity(0.8))
                            
                            Text("This achievement directly contributed to your performance momentum and resilience profile.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.sparcCard)
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 25)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                appear = true
            }
        }
    }
}
