import Foundation
import AVFoundation

class AudioCapture {
  private let audioEngine: AVAudioEngine = AVAudioEngine()

  init() {}
  
  deinit{
    audioEngine.inputNode.removeTap(onBus: 0)
    audioEngine.reset()
  }
  
  public func startSession(bufferSize: UInt32, cb: @escaping (_ buffer: Array<Float>) -> Void) throws {
    audioEngine.inputNode.removeTap(onBus: 0)
    audioEngine.reset()

    let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    try audioSession.setCategory(AVAudioSession.Category.playAndRecord,
                                  mode: AVAudioSession.Mode.default,
                                  options: [.allowBluetoothA2DP, .allowAirPlay, .allowBluetooth])
    try audioSession.setActive(true)

    let inputNode = audioEngine.inputNode

    let inputFormat  = inputNode.inputFormat(forBus: 0)

    inputNode.installTap(onBus: 0,
                          bufferSize: bufferSize,
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
