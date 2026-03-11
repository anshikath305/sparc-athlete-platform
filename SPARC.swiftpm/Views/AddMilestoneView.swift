//
//  AddMilestoneView.swift
//  SPARC
//
//  Created by Anshika Thakur on 25/02/26.
//
import SwiftUI
import UIKit

struct AddMilestoneView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: MilestoneManager
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDate = Date()
    
    @State private var appear = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, description
    }
    
    var body: some View {
        ZStack {
            
            // MARK: Background Atmosphere
            
            Color.sparcBackground
                .ignoresSafeArea()
            
            RadialGradient(
                colors: [
                    Color.sparcCyan.opacity(0.15),
                    Color.clear
                ],
                center: .top,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            
            VStack(spacing: 35) {
                
                Text("Add Milestone")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : -20)
                
                
                // MARK: Glass Card Container
                
                VStack(spacing: 22) {
                    
                    // Title
                    TextField("Milestone Title", text: $title)
                        .padding()
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                        .background(glassBackground(focused: focusedField == .title))
                        .focused($focusedField, equals: .title)
                    
                    // Description
                    TextEditor(text: $description)
                        .scrollContentBackground(.hidden)
                        .padding()
                        .frame(height: 130)
                        .foregroundColor(.white)
                        .font(.system(size: 15))
                        .background(glassBackground(focused: focusedField == .description))
                        .focused($focusedField, equals: .description)
                    
                    // Date
                    HStack {
                        Text("Date")
                            .foregroundColor(.gray)
                            .font(.system(size: 15, weight: .medium))
                        
                        Spacer()
                        
                        DatePicker(
                            "",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .colorScheme(.dark)
                    }
                    .padding()
                    .background(glassBackground(focused: false))
                    
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white.opacity(0.03))
                        )
                )
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 30)
                
                
                // MARK: Save Button
                
                Button {
                    if !title.isEmpty {
                        
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                            manager.addMilestone(
                                title: title,
                                description: description,
                                date: selectedDate
                            )
                        }
                        
                        dismiss()
                    }
                } label: {
                    Text("Save Milestone")
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
                        .cornerRadius(20)
                        .shadow(color: .sparcCyan.opacity(0.5), radius: 12)
                }
                .scaleEffect(appear ? 1 : 0.95)
                .opacity(appear ? 1 : 0)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appear = true
            }
        }
    }
    
    
    // MARK: Reusable Glass Background
    
    private func glassBackground(focused: Bool) -> some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color.sparcCard)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        focused
                        ? LinearGradient(
                            colors: [.sparcCyan, .sparcViolet],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        : LinearGradient(
                            colors: [Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            )
    }
}
