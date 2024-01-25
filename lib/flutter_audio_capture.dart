import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

const AUDIO_CAPTURE_EVENT_CHANNEL_NAME = "ymd.dev/audio_capture_event_channel";
const AUDIO_CAPTURE_METHOD_CHANNEL_NAME = "ymd.dev/audio_capture_method_channel";

const ANDROID_AUDIOSRC_DEFAULT = 0;
const ANDROID_AUDIOSRC_MIC = 1;
const ANDROID_AUDIOSRC_CAMCORDER = 5;
const ANDROID_AUDIOSRC_VOICERECOGNITION = 6;
const ANDROID_AUDIOSRC_VOICECOMMUNICATION = 7;
const ANDROID_AUDIOSRC_UNPROCESSED = 9;

class FlutterAudioCapture {
  static const _audioCaptureEventChannel = EventChannel(AUDIO_CAPTURE_EVENT_CHANNEL_NAME);

  // ignore: cancel_subscriptions
  StreamSubscription? _audioCaptureEventChannelSubscription;

  static const _audioCaptureMethodChannel = MethodChannel(AUDIO_CAPTURE_METHOD_CHANNEL_NAME);

  double? _actualSampleRate;

  bool? _initialized;


  Future<bool?> init() async {
    // Only init once
    if (_initialized != null) return _initialized;
    _initialized = await _audioCaptureMethodChannel.invokeMethod<bool>("init");
    return _initialized;
  }


  /// Starts listenening to audio.
  ///
  /// Uses [sampleRate] and [bufferSize] for capturing audio.
  /// Uses [androidAudioSource] to determine recording type on Android.
  /// When [waitForFirstDataOnAndroid] is set, it waits for [firstDataTimeout] duration on first data to arrive.
  /// Will not listen if first date does not arrive in time. Set as [true] by default on Android.
  /// When [waitForFirstDataOnIOS] is set, it waits for [firstDataTimeout] duration on first data to arrive.
  /// Known to not work reliably on iOS and set as [false] by default.
  Future<void> start(void Function(Float32List) listener, Function onError,
      {int sampleRate = 44100, int bufferSize = 5000, int androidAudioSource = ANDROID_AUDIOSRC_DEFAULT,
        Duration firstDataTimeout = const Duration(seconds: 1),
        bool waitForFirstDataOnAndroid = true, bool waitForFirstDataOnIOS = false}) async {
    if (_initialized == null) {
      throw Exception("FlutterAudioCapture must be initialized before use");
    }

    if (_initialized == false) {
      throw Exception("FlutterAudioCapture failed to initialize");
    }

    // We are already listening
    if (_audioCaptureEventChannelSubscription != null) return;
    // init channel stream
    final stream = _audioCaptureEventChannel.receiveBroadcastStream({
      "sampleRate": sampleRate,
      "bufferSize": bufferSize,
      "audioSource": androidAudioSource,
    }).cast<Map>();
    // The channel will have format:
    // {
    //   "audioData": Float32List,
    //   "actualSampleRate": double,
    // }

    _actualSampleRate = null;
    var audioStream = stream.map((event) {
      _actualSampleRate = event.get('actualSampleRate');
      return event.get('audioData') as Float32List;
    });


    // Do we need to wait for first data?
    final waitForFirstData = (Platform.isAndroid && waitForFirstDataOnAndroid) ||
        (Platform.isIOS && waitForFirstDataOnIOS);


    Completer<void>? completer = Completer();
    // Prevent stream for starting over because we have no listenre between firstWhere check and this line which initally was at the end of the code
    _audioCaptureEventChannelSubscription = audioStream.skipWhile((element) => !completer.isCompleted).listen(listener, onError: onError);
    if (waitForFirstData) {
      await audioStream.firstWhere((element) => (_actualSampleRate ?? 0) > 10).timeout(firstDataTimeout);
    }
    completer.complete();

  }

  Future<void> stop() async {
    if (_audioCaptureEventChannelSubscription == null) //
      return;
    final tempListener = _audioCaptureEventChannelSubscription;
    _audioCaptureEventChannelSubscription = null;
    await tempListener!.cancel();
  }

  double? get actualSampleRate => _actualSampleRate;
}


extension MapUtil on Map{
  T get<T>(String key) {
    return this[key]!;
  }

  T? getOrNull<T>(String key) {
    return this[key];
  }
}