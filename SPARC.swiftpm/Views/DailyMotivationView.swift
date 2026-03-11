import SwiftUI

struct DailyMotivationView: View {
    @Binding var isPresented: Bool
    
    let quotes = [
        "The only way to prove that you’re a good sport is to lose.",
        "Age is no barrier. It’s a limitation you put on your mind.",
        "A trophy carries dust. Memories last forever.",
        "The more difficult the victory, the greater the happiness in winning.",
        "One man can be a crucial ingredient on a team, but one man cannot make a team.",
        "Winning isn’t everything, but wanting to win is.",
        "You miss 100% of the shots you don’t take.",
        "Hard work beats talent when talent doesn’t work hard.",
        "The mind is the limit. As long as the mind can envision the fact that you can do something, you can do it.",
        "Persistence can change failure into extraordinary achievement.",
        "The difference between the impossible and the possible lies in a person’s determination."
    ]
    
    @State private var currentQuote = ""
    @State private var appear = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
            
            VStack(spacing: 30) {
                
                Image(systemName: "quote.opening")
                    .font(.system(size: 40))
                    .foregroundColor(.sparcCyan)
                    .opacity(0.6)
                
                Text(currentQuote)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .italic()
                
                Text("- Athlete Mindset")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer().frame(height: 20)
                
                Button {
                    dismiss()
                } label: {
                    Text("Fuel Up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [.sparcCyan, .sparcViolet], startPoint: .leading, endPoint: .trailing))
                        )
                }
                .shadow(color: .sparcCyan.opacity(0.4), radius: 10)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.sparcCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(LinearGradient(colors: [.sparcCyan.opacity(0.3), .sparcViolet.opacity(0.1)], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                    )
            )
            .padding(20)
            .scaleEffect(appear ? 1.0 : 0.8)
            .opacity(appear ? 1.0 : 0.0)
        }
        .onAppear {
            currentQuote = quotes.randomElement() ?? quotes[0]
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appear = true
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeIn(duration: 0.3)) {
            appear = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}
