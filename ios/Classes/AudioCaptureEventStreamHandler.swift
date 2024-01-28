enum AudioCaptureEventStreamHandlerErrorCode {
    static let onListenFailed = "ON_LISTEN_FAILED"
    static let whileListeningFailed = "WHILE_LISTENING_FAILED"
}

class AudioCaptureEventStreamHandler: NSObject, FlutterStreamHandler {
    let eventChannelName = "ymd.dev/audio_capture_event_channel"
    let audioCapture = AudioCapture()
    var eventSink: FlutterEventSink?
    var actualSampleRate:Float64?
    
    func setup() throws -> Bool {
        return try audioCapture.setup()
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        let args = arguments as? Dictionary<String, Any> ?? [:]
        let bufferSize: UInt32 = args["bufferSize"] as? UInt32 ?? 4000
        let sampleRate: Double = args["sampleRate"] as? Double ?? 16000.0
        actualSampleRate = sampleRate
        do {
            try audioCapture.startSession(bufferSize: bufferSize, sampleRate: sampleRate) { buffer, sampleRate, err in
                if let e = err {
                    self.sendToFlutter(FlutterError(code: AudioCaptureEventStreamHandlerErrorCode.whileListeningFailed,
                                                    message: "Error occured while starting audio capture",
                                                    details: e.localizedDescription))
                } else if let audioData = buffer {
                    self.sendToFlutter([
                        "actualSampleRate": sampleRate,
                        "audioData": audioData
                    ])
                }
            }
        } catch let error{
            sendToFlutter(FlutterError(code: AudioCaptureEventStreamHandlerErrorCode.onListenFailed,
                                       message: "Error occured while starting audio capture",
                                       details: error.localizedDescription))
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        actualSampleRate = nil
        audioCapture.stopSession()
        return nil
    }
    
    private func sendToFlutter(_ event: Any) {
        DispatchQueue.main.async {
            self.eventSink?(event)
        }
    }
}
