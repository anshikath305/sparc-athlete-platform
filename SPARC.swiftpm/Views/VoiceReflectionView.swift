//
//  VoiceReflectionView.swift
//  SPARC
//
//  Created by Anshika Thakur on 25/02/26.
//

import SwiftUI

struct VoiceReflectionView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var recorder = VoiceRecordingManager()
    @State private var micPulse = false
    
    var body: some View {
        ZStack {
            Color.sparcBackground
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                Text("Voice Reflection")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                // MARK: - Animated Mic
                
                ZStack {
                    
                    if recorder.isRecording {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.sparcCyan, .sparcViolet],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 6
                            )
                            .scaleEffect(micPulse ? 1.35 : 1.0)
                            .opacity(micPulse ? 0.15 : 0.6)
                            .animation(
                                .easeOut(duration: 1.2)
                                .repeatForever(autoreverses: false),
                                value: micPulse
                            )
                    }
                    
                    Button {
                        if recorder.isRecording {
                            recorder.stopRecording()
                        } else {
                            recorder.startRecording()
                        }
                    } label: {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.sparcCyan, .sparcViolet],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                                    .foregroundColor(.black)
                                    .font(.system(size: 40))
                            )
                            .shadow(color: .sparcCyan.opacity(0.6), radius: 20)
                    }
                }
                .onChange(of: recorder.isRecording) { recording in
                    micPulse = recording
                }
                
                Text(recorder.isRecording ? "Recording..." : "Tap to Record")
                    .foregroundColor(.gray)
                
                
                // MARK: - Recordings List
                
                ScrollView {
                    ForEach(recorder.recordings) { recording in
                        
                        VStack(spacing: 18) {
                            
                            Text(recording.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            // Spotify-style progress bar
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 4)
                                
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.sparcCyan, .sparcViolet],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: CGFloat(recorder.currentTime / max(recorder.duration, 1)) * 250,
                                        height: 4
                                    )
                            }
                            .frame(width: 250)
                            
                            // Controls
                            HStack(spacing: 40) {
                                
                                Button {
                                    recorder.stopPlayback()
                                } label: {
                                    Image(systemName: "backward.end.fill")
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                Button {
                                    if recorder.isPlaying {
                                        recorder.pausePlayback()
                                    } else {
                                        recorder.startPlayback(recording)
                                    }
                                } label: {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.sparcCyan, .sparcViolet],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 55, height: 55)
                                        .overlay(
                                            Image(systemName: recorder.isPlaying ? "pause.fill" : "play.fill")
                                                .foregroundColor(.black)
                                        )
                                        .shadow(color: .sparcCyan.opacity(0.5), radius: 8)
                                }
                                
                                Button {
                                    recorder.stopPlayback()
                                } label: {
                                    Image(systemName: "stop.fill")
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            
                            // Volume
                            Slider(
                                value: Binding(
                                    get: { recorder.volume },
                                    set: { recorder.updateVolume($0) }
                                ),
                                in: 0...1
                            )
                            .accentColor(.sparcCyan)
                            .frame(width: 200)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.sparcCard)
                        )
                    }
                }
                
                Button("Done") {
                    dismiss()
                }
                .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
        }
    }
}
