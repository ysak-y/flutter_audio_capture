import 'dart:async';

import 'package:flutter/services.dart';

const AUDIO_CAPTURE_EVENT_CHANNEL_NAME = "ymd.dev/audio_capture_event_channnel";

class FlutterAudioCapture {
  final EventChannel _audioCaptureEventChannel =
      EventChannel(AUDIO_CAPTURE_EVENT_CHANNEL_NAME);
  StreamSubscription _audioCaptureEventChannelSubscription;

  Future<void> start(Function listener, Function onError) async {
    if (_audioCaptureEventChannelSubscription != null) return;
    _audioCaptureEventChannelSubscription = _audioCaptureEventChannel
        .receiveBroadcastStream()
        .listen(listener, onError: onError);
  }

  Future<void> stop() async {
    if (_audioCaptureEventChannelSubscription == null) return;
    _audioCaptureEventChannelSubscription.cancel();
    _audioCaptureEventChannelSubscription = null;
  }
}
