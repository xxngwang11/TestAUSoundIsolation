//
//  AudioManager.swift
//  SoundIsolationDemo
//
//  Manages AVAudioEngine with Sound Isolation Audio Unit
//

import Foundation
import AVFoundation
import AudioToolbox

class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var selectedFileName: String?
    @Published var lastError: String?
    @Published var warningMessage: String?
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var audioFile: AVAudioFile?
    private var soundIsolationUnit: AVAudioUnitEffect?
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            lastError = "Failed to setup audio session: \(error.localizedDescription)"
            print("Audio session error: \(error)")
        }
    }
    
    func loadAudioFile(url: URL) {
        do {
            // Stop any current playback
            stop()
            
            // Load the audio file
            audioFile = try AVAudioFile(forReading: url)
            selectedFileName = url.lastPathComponent
            lastError = nil
            warningMessage = nil
            
            // Setup the audio engine with Sound Isolation
            setupAudioEngine()
            
        } catch {
            lastError = "Failed to load audio file: \(error.localizedDescription)"
            selectedFileName = nil
            print("Load error: \(error)")
        }
    }
    
    private func setupAudioEngine() {
        // Create a new audio engine
        audioEngine = AVAudioEngine()
        guard let engine = audioEngine else { return }
        
        // Create player node
        playerNode = AVAudioPlayerNode()
        guard let player = playerNode else { return }
        
        // Attach player to engine
        engine.attach(player)
        
        // Create Sound Isolation Audio Unit
        // AudioComponentDescription for kAudioUnitSubType_AUSoundIsolation
        let soundIsolationDescription = AudioComponentDescription(
            componentType: kAudioUnitType_Effect,              // Effect type
            componentSubType: kAudioUnitSubType_AUSoundIsolation,  // Sound Isolation subtype
            componentManufacturer: kAudioUnitManufacturer_Apple,   // Apple manufacturer
            componentFlags: 0,
            componentFlagsMask: 0
        )
        
        // Instantiate the Audio Unit Effect
        soundIsolationUnit = AVAudioUnitEffect(audioComponentDescription: soundIsolationDescription)
        
        // Attach Sound Isolation unit to engine
        if let soundIsolation = soundIsolationUnit {
            engine.attach(soundIsolation)
            
            // Connect nodes in the signal chain:
            // Player -> Sound Isolation -> Output
            // This is where the AU is inserted into the signal chain
            if let format = audioFile?.processingFormat {
                engine.connect(player, to: soundIsolation, format: format)
                engine.connect(soundIsolation, to: engine.mainMixerNode, format: format)
            }
        } else {
            // Fallback if Sound Isolation unit cannot be created
            // Connect directly: Player -> Output
            warningMessage = "Sound Isolation unit not available, playing without effect"
            if let format = audioFile?.processingFormat {
                engine.connect(player, to: engine.mainMixerNode, format: format)
            }
        }
        
        // Prepare the engine
        engine.prepare()
    }
    
    func play() {
        guard let engine = audioEngine,
              let player = playerNode,
              let file = audioFile else {
            lastError = "Audio engine not ready"
            return
        }
        
        do {
            // Start the engine if not already running
            if !engine.isRunning {
                try engine.start()
            }
            
            // Schedule the file for playback
            player.scheduleFile(file, at: nil) { [weak self] in
                DispatchQueue.main.async {
                    self?.isPlaying = false
                }
            }
            
            // Start playback
            player.play()
            isPlaying = true
            lastError = nil
            
        } catch {
            lastError = "Playback error: \(error.localizedDescription)"
            isPlaying = false
            print("Play error: \(error)")
        }
    }
    
    func stop() {
        playerNode?.stop()
        audioEngine?.stop()
        isPlaying = false
    }
    
    deinit {
        stop()
    }
}
