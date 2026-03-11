import SwiftUI

struct ActionButton: View {
    
    var icon: String
    var label: String
    
    var body: some View {
        HStack(spacing: 12) {
            
            Image(systemName: icon)
                .foregroundColor(.black)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.sparcCyan, .sparcViolet],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            Text(label)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .medium))
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.sparcCard)
        )
        .shadow(color: .sparcCyan.opacity(0.3), radius: 6)
    }
}
