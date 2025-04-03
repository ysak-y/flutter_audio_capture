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
    
    do {
        // Ensure the audio category is correctly set
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.mixWithOthers])
        
        // Set a preferred sample rate
        try audioSession.setPreferredSampleRate(44100.0)

        // Ensure the audio session is activated
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Check if input is available (to prevent recording issues)
        guard audioSession.isInputAvailable else {
            print("⚠️ Audio input is not available.")
            return false
        }

        print("✅ Audio session successfully activated.")
        return true
    } catch {
        print("❌ Failed to activate AudioSession: \(error.localizedDescription)")
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
    let inputFormat = inputNode.inputFormat(forBus: 0)
    
    // Ensure input format has a valid sample rate
    if inputFormat.sampleRate == 0 {
        throw NSError(domain: "AudioCapture", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid sample rate"])
    }

    // Create an appropriate format
    let formatToConvert = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: false)
    
    inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: inputFormat) { (buffer, _) in
        guard let converter = AVAudioConverter(from: inputFormat, to: formatToConvert!) else {
            cb(nil, sampleRate, NSError(domain: "AudioCapture", code: -1, userInfo: [NSLocalizedDescriptionKey: "AVAudioConverter initialization failed"]))
            return
        }

        let convertedBuffer = AVAudioPCMBuffer(pcmFormat: formatToConvert!, frameCapacity: buffer.frameCapacity)
        let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }
        
        var error: NSError?
        converter.convert(to: convertedBuffer!, error: &error, withInputFrom: inputBlock)
        
        if let error = error {
            cb(nil, sampleRate, error)
            return
        }
        
        let data = Data(buffer: UnsafeBufferPointer(start: convertedBuffer!.floatChannelData![0], count: Int(convertedBuffer!.frameLength)))
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