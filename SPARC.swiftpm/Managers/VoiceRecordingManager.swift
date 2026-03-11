//
//  VoiceRecordingManager.swift
//  SPARC
//
//  Created by Anshika Thakur on 25/02/26.
//

import Foundation
import AVFoundation

@MainActor
final class VoiceRecordingManager: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @Published var isRecording = false
    @Published var recordings: [VoiceReflection] = []
    private let key = "sparc_voice_reflections"
    
    override init() {
        super.init()
        load()
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(recordings) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([VoiceReflection].self, from: data) {
            recordings = decoded
        }
    }
    
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    @Published var volume: Float = 1.0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    
    
    // MARK: - Recording
    
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            let url = getFileURL()
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            
        } catch {
            // Handle recording failure silently or via UI
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        
        if let url = audioRecorder?.url {
            let fileName = url.lastPathComponent
            let reflection = VoiceReflection(fileName: fileName, date: Date())
            recordings.insert(reflection, at: 0)
            save()
        }
    }
    
    // MARK: - Playback
    
    func startPlayback(_ recording: VoiceReflection) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
            audioPlayer?.delegate = self
            audioPlayer?.volume = volume
            audioPlayer?.play()
            
            duration = audioPlayer?.duration ?? 1
            isPlaying = true
            
            updateProgress()
            
        } catch {
            // Handle playback failure silently or via UI
        }
    }
    private func updateProgress() {
        guard let player = audioPlayer, player.isPlaying else { return }
        
        currentTime = player.currentTime
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.updateProgress()
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func resumePlayback() {
        audioPlayer?.play()
        isPlaying = true
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        currentTime = 0
        
    }
    
    func updateVolume(_ value: Float) {
        volume = value
        audioPlayer?.volume = value
    }
    
    
    
    
    private func getFileURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths.first ?? FileManager.default.temporaryDirectory
        return documentDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
    }
}
