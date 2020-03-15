enum AudioCaptureEventStreamHandlerErrorCode {
  static let onListenFailed = "ON_LISTEN_FAILED"
  static let onCancelFailed = "ON_CANCEL_FAILED"
}

class AudioCaptureEventStreamHandler: NSObject, FlutterStreamHandler {
  public let eventChannelName = "ymd.dev/audio_capture_event_channnel"
  private let audioCapture: AudioCapture = AudioCapture()
  private var eventSink: FlutterEventSink?

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    if let sink: FlutterEventSink = self.eventSink {
      do {
        try self.audioCapture.startSession() { buffer in
          sink(buffer)
        }
      } catch {
        sink(FlutterError(code: AudioCaptureEventStreamHandlerErrorCode.onListenFailed,
                        message: "Error occured in onListen",
                        details: nil))
      }
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    if let sink: FlutterEventSink = self.eventSink {
      do {
        try self.audioCapture.stopSession()
      } catch {
        sink(FlutterError(code: AudioCaptureEventStreamHandlerErrorCode.onCancelFailed,
                        message: "Error occured in onCancel",
                        details: nil))
      }
    }
    return nil
  }
}
