import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_audio_capture/interface.dart';

const AUDIO_CAPTURE_EVENT_CHANNEL_NAME = "ymd.dev/audio_capture_event_channel";

class FlutterAudioCapture implements IAudioCapture {
  final EventChannel _audioCaptureEventChannel =
      EventChannel(AUDIO_CAPTURE_EVENT_CHANNEL_NAME);
  StreamSubscription? _audioCaptureEventChannelSubscription;

  @override
  Future<void> start(Function listener, Function onError,
      {int sampleRate = 44000, int bufferSize = 5000}) async {
    if (_audioCaptureEventChannelSubscription != null) return;
    _audioCaptureEventChannelSubscription = _audioCaptureEventChannel
        .receiveBroadcastStream({
      "sampleRate": sampleRate,
      "bufferSize": bufferSize
    }).listen(listener as void Function(dynamic)?, onError: onError);
  }

  @override
  Future<void> stop() async {
    if (_audioCaptureEventChannelSubscription == null) return;
    _audioCaptureEventChannelSubscription!.cancel();
    _audioCaptureEventChannelSubscription = null;
  }
}
