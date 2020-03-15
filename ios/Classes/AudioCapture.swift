import Foundation
import AVFoundation

class AudioCapture {
  private let audioEngine: AVAudioEngine = AVAudioEngine()

  deinit{
    audioEngine.inputNode.removeTap(onBus: 0)
    audioEngine.reset()
  }

  public func startSession(cb: @escaping (_ buffer: Array<Float>) -> Void) throws {
    // Reset the audio engine
    audioEngine.inputNode.removeTap(onBus: 0)
    audioEngine.reset()

    // Configure the audio session for the app.
    let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    try audioSession.setCategory(AVAudioSession.Category.playAndRecord,
                                  mode: AVAudioSession.Mode.default,
                                  options: [.allowBluetoothA2DP, .allowAirPlay, .allowBluetooth])
    try audioSession.setActive(true)

    let inputNode = audioEngine.inputNode

    let inputFormat  = inputNode.inputFormat(forBus: 0)
    // let outputFormat = inputNode.outputFormat(forBus: 0)

    print("input",  inputFormat)

    inputNode.installTap(onBus: 0,
                          bufferSize: 16384,
                          format: inputFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                          cb(Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count:Int(buffer.frameLength))))
    }

    audioEngine.prepare()
    try audioEngine.start()
  }

  public func stopSession() throws {
    let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    audioEngine.stop()
  }
}
