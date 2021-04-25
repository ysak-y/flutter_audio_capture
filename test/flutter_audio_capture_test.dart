import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';

class CallbackClass {
  void onListen() {}
  void onCancel() {}
}

class MockCallbackClass extends Mock implements CallbackClass {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const AUDIO_CAPTURE_EVENT_CHANNEL_NAME =
      "ymd.dev/audio_capture_event_channel";
  late MethodChannel channel;
  MockCallbackClass? mock;

  setUp(() {
    channel = MethodChannel(AUDIO_CAPTURE_EVENT_CHANNEL_NAME);
    mock = MockCallbackClass();
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
    reset(mock);
  });

  void setupMockMethodCallHandlerWithMockFunctions(
      Function mockOnListen, Function mockOnCancel) {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case "listen":
          {
            mockOnListen();
            break;
          }
        case "cancel":
          {
            mockOnCancel();
            break;
          }
        default:
          {
            throw "Error occured in mock methodCallHandler";
          }
      }
    });
  }

  test('listens stream of ymd.dev/audio_capture_event_channel channel',
      () async {
    setupMockMethodCallHandlerWithMockFunctions(mock!.onListen, mock!.onCancel);

    final client = FlutterAudioCapture();
    await client.start((dynamic obj) => {}, (Object e) => {});
    verify(mock!.onListen()).called(1);
    verifyNever(mock!.onCancel());
  });

  test('cancels to listen stream ymd.dev/audio_capture_event_channel channel',
      () async {
    setupMockMethodCallHandlerWithMockFunctions(mock!.onListen, mock!.onCancel);

    final client = FlutterAudioCapture();
    await client.start((dynamic obj) => {}, (Object e) => {});
    await client.stop();
    verify(mock!.onCancel()).called(1);
  });

  test('nothing happens if stop() is called before start()', () async {
    setupMockMethodCallHandlerWithMockFunctions(mock!.onListen, mock!.onCancel);

    final client = FlutterAudioCapture();
    await client.stop();
    await client.start((dynamic obj) => {}, (Object e) => {});
    verifyNever(mock!.onCancel());
  });

  test('executes only once whether start() is called many times', () async {
    setupMockMethodCallHandlerWithMockFunctions(mock!.onListen, mock!.onCancel);

    final client = FlutterAudioCapture();
    await client.stop();
    await client.start((dynamic obj) => {}, (Object e) => {});
    verifyNever(mock!.onCancel());
  });
}
