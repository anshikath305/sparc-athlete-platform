import SwiftUI

struct AchievementMediaViewer: View {
    
    let achievements: [Achievement]
    let startIndex: Int
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int
    @GestureState private var dragOffset: CGSize = .zero
    
    init(achievements: [Achievement], startIndex: Int) {
        self.achievements = achievements
        self.startIndex = startIndex
        _currentIndex = State(initialValue: startIndex)
    }
    
    var body: some View {
        ZStack {
            
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                
                ForEach(Array(achievements.enumerated()), id: \.element.id) { index, achievement in
                    
                    if let data = achievement.imageData,
                       let uiImage = UIImage(data: data) {
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .tag(index)
                            .padding()
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .offset(y: dragOffset.height)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        if value.translation.height > 150 {
                            dismiss()
                        }
                    }
            )
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.9))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}
