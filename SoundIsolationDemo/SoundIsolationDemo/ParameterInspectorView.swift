//
//  ParameterInspectorView.swift
//  SoundIsolationDemo
//
//  Parameter inspection UI for Audio Unit parameters
//

import SwiftUI
import AVFoundation

struct ParameterInspectorView: View {
    @ObservedObject var audioManager: AudioManager
    @State private var parameters: [AUParameterInfo] = []
    @State private var parameterValues: [AUParameterAddress: Float] = [:]
    
    // Delay for Audio Unit initialization before reading parameters
    private let parameterReloadDelay: TimeInterval = 0.5
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Audio Unit Parameters")
                .font(.headline)
                .padding(.horizontal)
            
            if parameters.isEmpty {
                Text("No public parameters exposed by this Audio Unit")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
            } else {
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(parameters) { paramInfo in
                            ParameterRow(
                                paramInfo: paramInfo,
                                value: Binding(
                                    get: { parameterValues[paramInfo.address] ?? paramInfo.value },
                                    set: { newValue in
                                        parameterValues[paramInfo.address] = newValue
                                        setParameterValue(address: paramInfo.address, value: newValue)
                                    }
                                )
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            loadParameters()
        }
        .onChange(of: audioManager.selectedFileName) { _ in
            // Reload parameters when a new file is loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + parameterReloadDelay) {
                loadParameters()
            }
        }
    }
    
    private func loadParameters() {
        parameters = []
        parameterValues = [:]
        
        guard let audioUnit = audioManager.audioUnit?.auAudioUnit else {
            return
        }
        
        // Get the parameter tree
        guard let parameterTree = audioUnit.parameterTree else {
            return
        }
        
        // Recursively collect all parameters from the tree
        collectParameters(from: parameterTree.allParameters)
    }
    
    private func collectParameters(from auParameters: [AUParameter]) {
        for param in auParameters {
            let info = AUParameterInfo(
                address: param.address,
                name: param.displayName,
                identifier: param.identifier,
                value: param.value,
                minValue: param.minValue,
                maxValue: param.maxValue,
                unit: param.unitName ?? ""
            )
            parameters.append(info)
            parameterValues[param.address] = param.value
        }
    }
    
    private func setParameterValue(address: AUParameterAddress, value: Float) {
        guard let audioUnit = audioManager.audioUnit?.auAudioUnit,
              let parameterTree = audioUnit.parameterTree,
              let parameter = parameterTree.parameter(withAddress: address) else {
            return
        }
        
        parameter.value = value
    }
}

struct ParameterRow: View {
    let paramInfo: AUParameterInfo
    @Binding var value: Float
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Parameter name and identifier
            HStack {
                Text(paramInfo.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("[\(paramInfo.address)]")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Slider and value
            HStack(spacing: 10) {
                Slider(value: $value, in: paramInfo.minValue...paramInfo.maxValue)
                
                Text(String(format: "%.2f", value))
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(minWidth: 50, alignment: .trailing)
            }
            
            // Range info
            HStack {
                Text("Range: [\(String(format: "%.2f", paramInfo.minValue)) - \(String(format: "%.2f", paramInfo.maxValue))]")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                if !paramInfo.unit.isEmpty {
                    Text(paramInfo.unit)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct AUParameterInfo: Identifiable {
    let id = UUID()
    let address: AUParameterAddress
    let name: String
    let identifier: String
    let value: Float
    let minValue: Float
    let maxValue: Float
    let unit: String
}

#Preview {
    ParameterInspectorView(audioManager: AudioManager())
}
