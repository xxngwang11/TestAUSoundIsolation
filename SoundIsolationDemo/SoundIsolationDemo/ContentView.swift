//
//  ContentView.swift
//  SoundIsolationDemo
//
//  Main UI for selecting and playing audio with Sound Isolation
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var showFilePicker = false
    @State private var statusText = "Select a WAV file to begin"
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Audio Unit Sound Isolation Demo")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
            
            // File Selection
            VStack(spacing: 15) {
                if let fileName = audioManager.selectedFileName {
                    Text("Selected: \(fileName)")
                        .font(.headline)
                        .foregroundColor(.blue)
                } else {
                    Text("No file selected")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    showFilePicker = true
                }) {
                    HStack {
                        Image(systemName: "folder")
                        Text("Select WAV File")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            
            // Playback Controls
            HStack(spacing: 20) {
                Button(action: {
                    audioManager.play()
                    statusText = "Playing with Sound Isolation..."
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(audioManager.isPlaying ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(audioManager.isPlaying || audioManager.selectedFileName == nil)
                
                Button(action: {
                    audioManager.stop()
                    statusText = "Stopped"
                }) {
                    HStack {
                        Image(systemName: "stop.fill")
                        Text("Stop")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(audioManager.isPlaying ? Color.red : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!audioManager.isPlaying)
            }
            .padding(.horizontal)
            
            // Status
            VStack(spacing: 10) {
                Text("Status")
                    .font(.headline)
                
                Text(statusText)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                if let error = audioManager.lastError {
                    Text("Error: \(error)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                if let warning = audioManager.warningMessage {
                    Text("Warning: \(warning)")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            // Parameter Inspector
            if audioManager.selectedFileName != nil {
                Divider()
                    .padding(.vertical, 10)
                
                ParameterInspectorView(audioManager: audioManager)
            }
            
            // Information
            VStack(alignment: .leading, spacing: 5) {
                Text("About:")
                    .font(.caption)
                    .fontWeight(.bold)
                
                Text("• Uses kAudioUnitSubType_AUSoundIsolation")
                Text("• Processes audio through AVAudioEngine")
                Text("• Supports WAV files")
                Text("• iOS 16+ required")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showFilePicker) {
            DocumentPicker(audioManager: audioManager) { result in
                switch result {
                case .success(let url):
                    statusText = "File loaded: \(url.lastPathComponent)"
                case .failure(let error):
                    statusText = "Error loading file: \(error.localizedDescription)"
                }
            }
        }
        .onReceive(audioManager.$isPlaying) { playing in
            if !playing && audioManager.selectedFileName != nil {
                statusText = "Playback finished"
            }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let audioManager: AudioManager
    let completion: (Result<URL, Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.wav])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(audioManager: audioManager, completion: completion)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let audioManager: AudioManager
        let completion: (Result<URL, Error>) -> Void
        
        init(audioManager: AudioManager, completion: @escaping (Result<URL, Error>) -> Void) {
            self.audioManager = audioManager
            self.completion = completion
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                completion(.failure(NSError(domain: "SoundIsolationDemo", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot access file"])))
                return
            }
            
            // Load the file
            audioManager.loadAudioFile(url: url)
            
            // Stop accessing after loading
            url.stopAccessingSecurityScopedResource()
            
            completion(.success(url))
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            completion(.failure(NSError(domain: "SoundIsolationDemo", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cancelled"])))
        }
    }
}

#Preview {
    ContentView()
}
