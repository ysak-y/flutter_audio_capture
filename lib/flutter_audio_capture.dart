import 'dart:async';

import 'package:flutter/services.dart';

const AUDIO_CAPTURE_METHOD_CHANNEL_NAME =
    'ymd.dev/audio_capture_method_channel';
const AUDIO_CAPTURE_EVENT_CHANNEL_NAME = "ymd.dev/audio_capture_event_channnel";

class FlutterAudioCapture {
  final MethodChannel _audioCaptureMethodChannel =
      MethodChannel(AUDIO_CAPTURE_METHOD_CHANNEL_NAME);
  final EventChannel _audioCaptureEventChannel =
      EventChannel(AUDIO_CAPTURE_EVENT_CHANNEL_NAME);
  StreamSubscription _audioCaptureEventChannelSubscription;

  Future<void> start(Function listener, Function onError) async {
    print(_audioCaptureEventChannelSubscription.toString());
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
