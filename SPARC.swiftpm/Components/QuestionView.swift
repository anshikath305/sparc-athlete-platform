//
//  QuestionView.swift
//  SPARC
//
//  Created by Anshika Thakur on 24/02/26.
//
import SwiftUI

struct QuestionView: View {
    
    var title: String
    var options: [String]
    @Binding var selection: String?
    
    var body: some View {
        VStack(spacing: 30) {
            
            Text(title)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
            
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selection = option
                    }
                } label: {
                    Text(option)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.sparcCard)
                                
                                if selection == option {
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.sparcCyan, .sparcViolet],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 2
                                        )
                                        .shadow(color: .sparcCyan.opacity(0.7), radius: 10)
                                } else {
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                }
                            }
                        )
                        .scaleEffect(selection == option ? 1.03 : 1.0)
                }
            }
        }
    }
}

