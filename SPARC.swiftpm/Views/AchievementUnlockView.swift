//
//  AchievementUnlockView.swift
//  SPARC
//
//  Created by Anshika Thakur on 28/02/26.
//

import SwiftUI

struct AchievementUnlockView: View {
    
    let milestone: Milestone?
    @State private var animate = false
    
    var body: some View {
        ZStack {
            
            // Dark overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                ZStack {
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.sparcCyan.opacity(0.8), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 150
                            )
                        )
                        .frame(width: 250, height: 250)
                        .scaleEffect(animate ? 1.2 : 0.5)
                        .opacity(animate ? 1 : 0)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.sparcCyan, .sparcViolet],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(animate ? 1 : 0.3)
                        .rotationEffect(.degrees(animate ? 360 : 0))
                }
                
                Text("Achievement Unlocked")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text(milestone?.title ?? "")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                animate = true
            }
        }
    }
}
