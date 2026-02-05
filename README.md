# TestAUSoundIsolation

iOS 16+ demo app showcasing Apple's Audio Unit Sound Isolation effect (`kAudioUnitSubType_AUSoundIsolation`) with AVAudioEngine.

## Overview

This SwiftUI application demonstrates how to:
- Use `UIDocumentPicker` to select WAV audio files
- Instantiate the Sound Isolation Audio Unit via `AudioComponentDescription`
- Insert the Audio Unit into an `AVAudioEngine` signal chain
- Process and play audio with the Sound Isolation effect applied

## Features

- **File Picker**: Select WAV files from your device using `UIDocumentPicker`
- **Sound Isolation Processing**: Applies Apple's Sound Isolation Audio Unit to isolate voice from background noise
- **AVAudioEngine Integration**: Uses `AVAudioEngine` with `AVAudioUnitEffect` for audio processing
- **Play/Stop Controls**: Simple UI to control audio playback
- **Status Display**: Real-time feedback on app state and any errors
- **Parameter Inspection**: View and adjust Audio Unit parameters in real-time
  - Enumerates all public parameters from the Audio Unit's AUParameterTree
  - Displays parameter name, address, current value, and min/max range
  - Provides sliders for real-time parameter adjustment
  - Shows clear message if no parameters are available

## Requirements

- **iOS 16.0+**
- **Xcode 15.0+**
- **Swift 5.9+**
- **Physical iPhone device** (Audio Units may not work properly in simulator)

## Audio Unit Details

The app uses the following Audio Unit configuration:
```swift
AudioComponentDescription(
    componentType: kAudioUnitType_Effect,
    componentSubType: kAudioUnitSubType_AUSoundIsolation,
    componentManufacturer: kAudioUnitManufacturer_Apple,
    componentFlags: 0,
    componentFlagsMask: 0
)
```

## Signal Chain

The audio processing signal chain is:
```
AVAudioPlayerNode → Sound Isolation Unit → Main Mixer Node → Output
```

This architecture allows the Sound Isolation Audio Unit to process the audio before it reaches the output.

## Build Instructions

### Using Xcode

1. **Clone the repository**:
   ```bash
   git clone https://github.com/xxngwang11/TestAUSoundIsolation.git
   cd TestAUSoundIsolation
   ```

2. **Open the project**:
   ```bash
   open SoundIsolationDemo/SoundIsolationDemo.xcodeproj
   ```

3. **Configure code signing**:
   - Select the `SoundIsolationDemo` target in Xcode
   - Go to "Signing & Capabilities"
   - Select your development team
   - Ensure a valid provisioning profile is selected

4. **Build and run**:
   - Connect your iPhone device
   - Select your device as the build target
   - Press `Cmd + R` or click the Run button
   - Grant any permission requests when prompted

### Using xcodebuild (Command Line)

```bash
cd SoundIsolationDemo

# Build for device
xcodebuild -project SoundIsolationDemo.xcodeproj \
           -scheme SoundIsolationDemo \
           -destination 'platform=iOS,name=Your iPhone Name' \
           build

# Or build for simulator (limited functionality)
xcodebuild -project SoundIsolationDemo.xcodeproj \
           -scheme SoundIsolationDemo \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           build
```

## Usage

1. **Launch the app** on your iPhone
2. **Tap "Select WAV File"** to open the file picker
3. **Choose a WAV audio file** from your device
4. **Tap "Play"** to start playback with Sound Isolation applied
5. **Tap "Stop"** to stop playback
6. **View and adjust parameters** in the Parameter Inspector section (appears after loading a file)
   - Use the sliders to adjust parameter values in real-time
   - Observe the effect on audio playback
7. Monitor the status area for feedback and error messages

## Project Structure

```
SoundIsolationDemo/
├── SoundIsolationDemo.xcodeproj/
│   └── project.pbxproj              # Xcode project configuration
└── SoundIsolationDemo/
    ├── SoundIsolationDemoApp.swift  # App entry point
    ├── ContentView.swift            # Main UI (file picker, controls, status)
    ├── ParameterInspectorView.swift # Audio Unit parameter inspection UI
    ├── AudioManager.swift           # AVAudioEngine & Audio Unit management
    ├── Info.plist                   # App configuration & permissions
    └── Assets.xcassets/             # App icons and resources
```

## Key Implementation Details

### AudioManager.swift
- Manages `AVAudioEngine` lifecycle
- Creates and configures the Sound Isolation Audio Unit
- Connects nodes in the signal chain: Player → Sound Isolation → Output
- Handles audio file loading and playback
- Exposes Audio Unit instance for parameter inspection

### ContentView.swift
- SwiftUI-based user interface
- Integrates `UIDocumentPicker` for file selection
- Provides play/stop controls
- Displays status and error messages
- Integrates parameter inspection UI

### ParameterInspectorView.swift
- Enumerates Audio Unit parameters from AUParameterTree
- Displays parameter details (name, address, value, range)
- Provides interactive sliders for real-time parameter adjustment
- Handles cases where no parameters are available
- Automatically updates when a new audio file is loaded

### Info.plist
- Includes `NSDocumentsFolderUsageDescription` for file access
- Configures document browser support

## Permissions

The app requires the following permissions:
- **File Access**: To read WAV files from your device (configured via `NSDocumentsFolderUsageDescription`)

## Testing

To test the app:
1. Prepare a WAV audio file with voice and background noise
2. Transfer it to your iPhone (via Files app, AirDrop, or iTunes)
3. Use the app to select and play the file
4. Observe how the Sound Isolation effect processes the audio

## Troubleshooting

**"Could not create Sound Isolation unit"**
- The Sound Isolation Audio Unit may not be available on all devices or iOS versions
- Ensure you're running iOS 16 or later
- Try running on a physical device instead of simulator

**File selection issues**
- Ensure the file is a valid WAV format
- Check that file access permissions have been granted

**Audio not playing**
- Check device volume
- Ensure no other apps are using the audio session
- Try stopping and restarting playback

## Technical Notes

- **Audio Format**: The app expects WAV files. The Sound Isolation unit processes the audio in the file's native format.
- **Performance**: Audio Unit processing happens in real-time during playback.
- **Simulator Limitations**: Audio Units may have limited functionality in the iOS Simulator. Testing on a physical device is recommended.

## License

This is a demo project for educational purposes.

## Contributing

Issues and pull requests are welcome!

## References

- [Audio Unit Programming Guide](https://developer.apple.com/library/archive/documentation/MusicAudio/Conceptual/AudioUnitProgrammingGuide/Introduction/Introduction.html)
- [AVAudioEngine Documentation](https://developer.apple.com/documentation/avfaudio/avaudioengine)
- [Sound Isolation on iOS](https://developer.apple.com/documentation/avfaudio/audio_engine/audio_units/using_voice_processing)