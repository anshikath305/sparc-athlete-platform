//
//   SplashView.swift
//  SPARC
//
//  Created by Anshika Thakur on 24/02/26.
//

import SwiftUI

struct SplashView: View {
    
    @State private var navigate = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.sparcBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    
                    SparkLogoView()
                    
                    Text("SPARC")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.sparcCyan, .sparcViolet],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("ignite your journey")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            .navigationDestination(isPresented: $navigate) {
                if UserDefaults.standard.bool(forKey: "sparc_onboarding_completed") {
                    DashboardView()
                        .navigationBarBackButtonHidden(true)
                } else {
                    QuizView()
                        .navigationBarBackButtonHidden(true)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    navigate = true
                }
            }
        }
    }
}
