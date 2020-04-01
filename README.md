# flutter_audio_capture

Capture the audio stream buffer through microphone for iOS/Android.
Required OS version is iOS 12+ or Android 23+

## Getting Started

Add this line to your pubspec.yaml file:

```
dependencies:
  flutter_audio_capture: ^0.0.2
```

and execute

```
$ flutter pub get
```

If you want to use this package on Android OS, you need to set `RECORD_AUDIO` permission to `AndroindManifest.xml` like below.

```
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
  package="com.ymd.flutter_audio_capture">
  ...
  // Add this line
  <uses-permission android:name="android.permission.RECORD_AUDIO"/>
</manifest>
```

If you want to use this package on iOS, you need to set `NSMicrophoneUsageDescription` to `Info.plist` like below.

```
<dict>
    <key>NSMicrophoneUsageDescription</key>
    <string>Need microphone access to capture audio</string>
...
```

## Example

You can see full example in `example/lib/main.dart`

```dart
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
...

// Callback function if device capture new audio stream.
// argument is audio stream buffer captured through mictophone.
// Currentry, you can only get is as Float64List.
void listener(dynamic obj) {
  var buffer = Float64List.fromList(obj.cast<double>());
  print(buffer);
}

// Callback function if flutter_audio_capture failure to register
// audio capture stream subscription.
void onError(Object e) {
  print(e);
}

...

FlutterAudioCapture plugin = new FlutterAudioCapture();
// Start to capture audio stream buffer
// sampleRate: sample rate you want
// bufferSize: buffer size you want (iOS only)
await plugin.start(listener, onError, sampleRate: 16000, bufferSize: 3000);
// Stop to capture audio stream buffer
await plugin.stop();
```
