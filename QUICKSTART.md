# Quick Start Guide

## Prerequisites

- Mac with macOS Ventura or later
- Xcode 15.0 or later
- Apple Developer account (for code signing)
- iPhone running iOS 16.0 or later

## Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone https://github.com/xxngwang11/TestAUSoundIsolation.git
cd TestAUSoundIsolation
```

### 2. Open in Xcode

```bash
open SoundIsolationDemo/SoundIsolationDemo.xcodeproj
```

Or double-click `SoundIsolationDemo.xcodeproj` in Finder.

### 3. Configure Code Signing

In Xcode:
1. Select the `SoundIsolationDemo` project in the navigator
2. Select the `SoundIsolationDemo` target
3. Go to the "Signing & Capabilities" tab
4. Under "Team", select your Apple Developer team
5. Xcode will automatically generate a provisioning profile

### 4. Connect Your iPhone

1. Connect your iPhone to your Mac via USB
2. Trust your Mac if prompted on your iPhone
3. In Xcode, select your iPhone from the device dropdown (next to the Run button)

### 5. Build and Run

Click the Run button (▶️) or press `⌘ + R`

Xcode will:
- Build the project
- Install the app on your iPhone
- Launch the app

### 6. Grant Permissions

When the app launches for the first time, you may need to:
- Grant file access permissions when prompted
- Trust the developer certificate on your iPhone:
  - Settings → General → VPN & Device Management
  - Tap your developer profile
  - Tap "Trust"

## Testing the App

### Prepare Test Audio

You'll need a WAV file to test. You can:
1. Record your own audio with background noise
2. Download sample WAV files from the internet
3. Convert other audio formats to WAV using tools like:
   - iTunes/Music app (export as WAV)
   - Online converters
   - ffmpeg: `ffmpeg -i input.mp3 output.wav`

### Transfer Audio to iPhone

Transfer your WAV file to your iPhone using:
- **AirDrop**: Right-click file on Mac → Share → AirDrop → Select your iPhone
- **Files App**: Save to iCloud Drive on Mac, access from Files app on iPhone
- **iTunes/Finder**: Connect iPhone and drag files to device

### Using the App

1. Launch "Sound Isolation Demo" on your iPhone
2. Tap "Select WAV File"
3. Navigate to and select your WAV file
4. Tap "Play" to hear the audio with Sound Isolation applied
5. Tap "Stop" to stop playback

## Troubleshooting

### Build Errors

**"No profiles for 'com.example.SoundIsolationDemo' were found"**
- Solution: Configure code signing (see step 3 above)

**"iPhone is busy: Preparing debugger support"**
- Solution: Wait a few seconds, then try running again

### Runtime Issues

**"Could not launch SoundIsolationDemo"**
- Solution: Trust the developer certificate on your iPhone (see step 6)

**"Sound Isolation unit not available"**
- This is normal on older devices or simulators
- The app will play audio without the effect as a fallback

**Cannot select audio file**
- Ensure the file is in WAV format
- Try saving the file to iCloud Drive first

### Device Issues

**App crashes on launch**
- Ensure iOS version is 16.0 or later
- Try cleaning and rebuilding: Product → Clean Build Folder (⌘ + Shift + K)

## Command Line Build (Advanced)

To build from the command line:

```bash
cd SoundIsolationDemo

# List available devices
xcrun xctrace list devices

# Build for your device (replace "Your iPhone" with your device name)
xcodebuild -project SoundIsolationDemo.xcodeproj \
           -scheme SoundIsolationDemo \
           -destination 'platform=iOS,name=Your iPhone' \
           build

# Or build for simulator
xcodebuild -project SoundIsolationDemo.xcodeproj \
           -scheme SoundIsolationDemo \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           build
```

## Next Steps

- Review the code in Xcode to understand the implementation
- Check `DEVELOPER_NOTES.md` for technical details
- Experiment with different audio files
- Try modifying the UI or adding features

## Support

For issues or questions:
- Open an issue on GitHub
- Check the README.md for detailed documentation
- Review DEVELOPER_NOTES.md for technical insights

## Resources

- [Apple's Audio Unit Documentation](https://developer.apple.com/documentation/audiotoolbox/audio_unit_v3)
- [AVAudioEngine Guide](https://developer.apple.com/documentation/avfaudio/avaudioengine)
- [Xcode Help](https://help.apple.com/xcode/)
