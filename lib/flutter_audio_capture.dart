import 'dart:async';

import 'package:flutter/services.dart';

const AUDIO_CAPTURE_EVENT_CHANNEL_NAME = "ymd.dev/audio_capture_event_channnel";

class FlutterAudioCapture {
  final EventChannel _audioCaptureEventChannel =
      EventChannel(AUDIO_CAPTURE_EVENT_CHANNEL_NAME);
  StreamSubscription _audioCaptureEventChannelSubscription;

  Future<void> start(Function listener, Function onError,
      {int sampleRate = 44000, int bufferSize = 5000}) async {
    if (_audioCaptureEventChannelSubscription != null) return;
    _audioCaptureEventChannelSubscription = _audioCaptureEventChannel
        .receiveBroadcastStream({
      "sampleRate": sampleRate,
      "bufferSize": bufferSize
    }).listen(listener, onError: onError);
  }

  Future<void> stop() async {
    if (_audioCaptureEventChannelSubscription == null) return;
    _audioCaptureEventChannelSubscription.cancel();
    _audioCaptureEventChannelSubscription = null;
  }
}
