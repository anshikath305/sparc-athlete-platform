//
//  PerformanceRing.swift
//  SPARC
//
//  Created by Anshika Thakur on 24/02/26.
//

import SwiftUI

struct PerformanceRing: View {
    
    var progress: Double
    
    var body: some View {
        ZStack {
            
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.sparcCyan, .sparcViolet]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: .sparcCyan.opacity(0.7), radius: 10)
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 200, height: 200)
    }
}
