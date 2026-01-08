# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

flutter_audio_capture is a Flutter plugin that captures audio stream buffer from the microphone. It supports iOS 13+, Android 23+, and Linux (with PulseAudio).

## Build and Development Commands

```bash
# Get dependencies
flutter pub get

# Run tests
flutter test

# Analyze code
flutter analyze

# Generate documentation
flutter pub global run dartdoc

# Run the example app (from example/ directory)
cd example && flutter run
```

## Architecture

This is a Flutter federated plugin with platform-specific implementations communicating via Flutter platform channels:

- **Dart API** (`lib/flutter_audio_capture.dart`): Main `FlutterAudioCapture` class using `EventChannel` for audio stream and `MethodChannel` for control commands
- **Android** (`android/src/main/kotlin/`): Kotlin implementation using `AudioRecord` API with a background thread for capturing. `AudioCaptureStreamHandler` handles the actual recording loop
- **iOS** (`ios/Classes/`): Swift implementation using `AVAudioEngine` with an audio tap for buffer capture. `AudioCapture` manages the audio session and engine
- **Linux** (`linux/`): C++ implementation spawning `parec` (PulseAudio recorder) subprocess and reading PCM data from its output

### Channel Names
- Event channel: `ymd.dev/audio_capture_event_channel`
- Method channel: `ymd.dev/audio_capture_method_channel`

### Usage Pattern
```dart
FlutterAudioCapture plugin = FlutterAudioCapture();
await plugin.init();  // Required before start()
await plugin.start(listener, onError, sampleRate: 16000, bufferSize: 3000);
await plugin.stop();
```

### Platform Permissions Required
- **Android**: `RECORD_AUDIO` permission in AndroidManifest.xml
- **iOS**: `NSMicrophoneUsageDescription` in Info.plist
- **Linux**: `pulseaudio` package with `parec` utility
