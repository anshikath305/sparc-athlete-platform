import SwiftUI

struct AchievementDetailView: View {
    
    let achievement: Achievement
    var animation: Namespace.ID
    
    @State private var appear = false
    
    var body: some View {
        
        ZStack {
            
            Color.sparcBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 35) {
                    
                    // MARK: HERO
                    
                    GeometryReader { geo in
                        ZStack(alignment: .bottomLeading) {
                            
                            if let data = achievement.imageData,
                               let uiImage = UIImage(data: data) {
                                
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geo.size.width, height: 350)
                                    .clipped()
                                    .matchedGeometryEffect(
                                        id: achievement.id,
                                        in: animation
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color.sparcCard)
                                    .frame(height: 350)
                            }
                            
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.85),
                                    Color.black.opacity(0.4),
                                    Color.clear
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                            
                            VStack(alignment: .leading, spacing: 6) {
                                
                                Text(achievement.title)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                
                                Text(achievement.year)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            .padding(20)
                            .frame(maxWidth: geo.size.width * 0.9, alignment: .leading)
                        }
                    }
                    .frame(height: 350)
                    .cornerRadius(28)
                    .padding(.horizontal)
                    .shadow(color: .sparcCyan.opacity(0.25), radius: 20)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 40)
                    
                    
                    // MARK: Reflection
                    
                    VStack(spacing: 20) {
                        
                        Text("Milestone Reflection")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("""
                        Every milestone represents discipline, resilience, and relentless effort. 
                        This moment stands as proof of growth, courage, and the pursuit of excellence.
                        """)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal)
                    }
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    
                    Spacer(minLength: 80)
                }
                .padding(.top)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appear = true
            }
        }
    }
}
