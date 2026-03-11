//
//  SparkLogoView.swift
//  SPARC
//
//  Created by Anshika Thakur on 24/02/26.
//

import SwiftUI

struct SparkLogoView: View {
    
    @State private var draw = false
    
    var body: some View {
        ZStack {
            
            SparkShape()
                .trim(from: 0, to: draw ? 1 : 0)
                .stroke(
                    LinearGradient(
                        colors: [.sparcCyan, .sparcViolet],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .shadow(color: .sparcCyan.opacity(0.8), radius: 12)
                .frame(width: 160, height: 160)
                .animation(.easeOut(duration: 1.2), value: draw)
        }
        .onAppear {
            draw = true
        }
    }
}

struct SparkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.1, y: height * 0.7))
        
        path.addCurve(
            to: CGPoint(x: width * 0.9, y: height * 0.3),
            control1: CGPoint(x: width * 0.4, y: height * 0.9),
            control2: CGPoint(x: width * 0.6, y: height * 0.1)
        )
        
        return path
    }
}
