import 'dart:async';
import 'dart:html';
import 'dart:web_audio';
import 'dart:typed_data';

import 'package:flutter_audio_capture/interface.dart';

class FlutterAudioCapture extends IAudioCapture {
  StreamController<Float64List>? controller;

  @override
  Future<void> start(Function listener, Function onError,
      {int sampleRate = 44000, int bufferSize = 5000}) async {
    if (controller == null) {
      controller = StreamController();
      controller!.stream.listen((event) {
        listener(event);
      }, onError: (error) {
        onError();
      });
      startRecording();
    }
  }

  @override
  Future<void> stop() async {
    if (controller != null) {
      await controller!.close();
      controller = null;
    }
  }

  Float64List _convertBytesToFloat64(dynamic buf) {
    return Float64List.fromList(buf);
  }

  startRecording() async {
    // build up stuff we need
    final stream = await window.navigator.mediaDevices!
        .getUserMedia({"audio": true, "video": false});
    final context = AudioContext();
    final source = context.createMediaStreamSource(stream);
    final processor = context.createScriptProcessor(4096, 1, 1);
    source.connectNode(processor);
    processor.connectNode(context.destination!);
    final audioStream = processor.onAudioProcess;
    var closed = false;
    audioStream.listen((e) async {
      var sr = e.inputBuffer!.sampleRate;
      var buf = e.inputBuffer!.getChannelData(0);
      if (controller != null &&
          !controller!.isClosed &&
          !controller!.isPaused &&
          !closed) {
        try {
          controller!.add(_convertBytesToFloat64(buf));
        } catch (e) {}
      } else {
        // cancel recording stuff...
        if (!closed) {
          closed = true;
          await context.close();
        }
      }
    });
  }
}
