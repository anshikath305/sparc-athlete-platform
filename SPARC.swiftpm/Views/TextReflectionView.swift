//
//  TextReflectionView.swift
//  SPARC
//
//  Created by Anshika Thakur on 25/02/26.
//

import SwiftUI

struct TextReflectionView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: ReflectionManager
    
    @State private var reflectionText = ""
    
    var body: some View {
        ZStack {
            Color.sparcBackground
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                Text("How did today shape you?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                
                TextEditor(text: $reflectionText)
                    .scrollContentBackground(.hidden)   // 🔥 hides default white background
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.sparcCard)
                    )
                    .foregroundColor(.white)
                    .tint(.sparcCyan)                   // cursor color
                    .frame(height: 200)
                
                Button {
                    if !reflectionText.isEmpty {
                        manager.addReflection(text: reflectionText)
                        dismiss()
                    }
                } label: {
                    Text("Save Reflection")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.sparcCyan, .sparcViolet],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}
