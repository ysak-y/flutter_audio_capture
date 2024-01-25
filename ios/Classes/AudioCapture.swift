import AVFoundation

/// `AudioCapture` is a class that handles audio recording and processing.
public class AudioCapture {
    /// `audioEngine` is an instance of `AVAudioEngine` used for audio input and output.
    let audioEngine = AVAudioEngine()

    /// `setup` is a method that sets up the audio session for recording.
    /// It sets the audio session category to `.record` and activates the audio session.
    /// - Returns: A boolean indicating whether the audio session was successfully activated.
    /// - Throws: An error if the audio session could not be set up.
    public func setup() throws -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [.mixWithOthers])
        do {
            try audioSession.setActive(true)
            return true
        } catch {
            print("Failed to activate AudioSession: \(error)")
            return false
        }
    }
    
    /// `startSession` is a method that starts the audio recording session.
    /// It installs a tap on the input node of the audio engine to capture audio data.
    /// - Parameters:
    ///   - bufferSize: The size of the buffer for the audio data.
    ///   - sampleRate: The sample rate for the audio data.
    ///   - cb: A callback function that is called with the audio data and sample rate.
    /// - Throws: An error if the audio engine could not be started.
    public func startSession(bufferSize: UInt32, sampleRate: Double, cb: @escaping (FlutterStandardTypedData?, Double, Error?) -> Void) throws {
        let inputNode = audioEngine.inputNode
        let inputFormat  = inputNode.inputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: inputFormat) { (buffer, _) in
            // Convert audio format from 44100Hz to passed sampleRate
            // https://medium.com/@prianka.kariat/changing-the-format-of-ios-avaudioengine-mic-input-c183459cab63
            let formatToConvert = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: true)!
            guard let converter = AVAudioConverter(from: inputFormat, to: formatToConvert) else {
                cb(nil, sampleRate, NSError(domain: "AudioCapture", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAudioConverter"]))
                return
            }
            let convertedBuffer: AVAudioPCMBuffer? = AVAudioPCMBuffer(pcmFormat:  formatToConvert, frameCapacity: AVAudioFrameCount(formatToConvert.sampleRate) * buffer.frameLength / AVAudioFrameCount(buffer.format.sampleRate))
            let inputBlock : AVAudioConverterInputBlock = { (_, outStatus) -> AVAudioBuffer? in
                outStatus.pointee = AVAudioConverterInputStatus.haveData
                return buffer
            }
            var error: NSError?
            converter.convert(to: convertedBuffer!, error: &error, withInputFrom: inputBlock)
            if let error = error {
                cb(nil, sampleRate, error)
                return
            }
            let data = Data(buffer: UnsafeBufferPointer(start: convertedBuffer!.floatChannelData![0], count:Int(convertedBuffer!.frameLength)))
            let flutterData = FlutterStandardTypedData(float32: data)
            cb(flutterData, sampleRate, nil)
        }
        
        try audioEngine.start()
    }
    
    /// `stopSession` is a method that stops the audio recording session.
    /// It removes the tap on the input node of the audio engine and stops the audio engine.
    public func stopSession() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
}
