import SwiftUI
import PhotosUI

struct AddAchievementView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var manager: ProfileManager
    
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    @State private var title = ""
    @State private var year = ""
    @State private var appear = false
    
    var body: some View {
        ZStack {
            
            Color.sparcBackground
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                // MARK: Title
                
                Text("New Achievement")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : -20)
                
                
                // MARK: Form Section
                
                VStack(spacing: 20) {
                    
                    TextField("Achievement Title", text: $title)
                        .padding()
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.sparcCard)
                        )
                    
                    TextField("Year (e.g. 2025)", text: $year)
                        .padding()
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.sparcCard)
                        )
                    
                    
                    // MARK: Image Preview Card
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.sparcCard)
                            .frame(height: 170)
                        
                        if let data = selectedImageData,
                           let uiImage = UIImage(data: data) {
                            
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 170)
                                .clipped()
                                .cornerRadius(18)
                            
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray)
                                
                                Text("Add Image (Optional)")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 13))
                            }
                        }
                    }
                    
                    
                    // MARK: Photos Picker Button
                    
                    PhotosPicker(
                        selection: $selectedImageItem,
                        matching: .images
                    ) {
                        Text("Select Image")
                            .foregroundColor(.sparcCyan)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .onChange(of: selectedImageItem) { _ in
                        Task {
                            if let data = try? await selectedImageItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
                
                
                // MARK: Save Button
                
                Button {
                    if !title.isEmpty && !year.isEmpty {
                        
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                            manager.profile.achievements.append(
                                Achievement(
                                    title: title,
                                    year: year,
                                    imageData: selectedImageData
                                )
                            )
                            manager.save()
                        }
                        
                        dismiss()
                    }
                } label: {
                    Text("Save Achievement")
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
                        .shadow(color: .sparcCyan.opacity(0.5), radius: 10)
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appear = true
            }
        }
    }
}
