enum AudioCaptureEventStreamHandlerErrorCode {
  static let onListenFailed = "ON_LISTEN_FAILED"
  static let onCancelFailed = "ON_CANCEL_FAILED"
}

class AudioCaptureEventStreamHandler: NSObject, FlutterStreamHandler {
  public let eventChannelName = "ymd.dev/audio_capture_event_channel"
  private let audioCapture: AudioCapture = AudioCapture()
  private var eventSink: FlutterEventSink?
  public var actualSampleRate:Float64?;

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events

    var bufferSize: UInt32 = 4000
    var sampleRate: Double = 16000.0
    if let args = arguments as? Dictionary<String, Any> {
      if args.keys.contains("bufferSize"),
          let bufSize = args["bufferSize"] as? UInt32 {
        bufferSize = bufSize
      }
      
      if args.keys.contains("sampleRate"),
          let rate = args["sampleRate"] as? Double {
        sampleRate = rate
      }
    }
    
    self.actualSampleRate = sampleRate; // This should come from audioCapture
    
    if let sink: FlutterEventSink = self.eventSink {
      do {
        try self.audioCapture.startSession(bufferSize: bufferSize, sampleRate: sampleRate) { buffer in
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
    self.actualSampleRate = nil

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
