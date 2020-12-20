import Foundation
import AVFoundation

class AudioCapture {
  private let audioEngine: AVAudioEngine = AVAudioEngine()

  init() {}
  
  deinit{
    audioEngine.inputNode.removeTap(onBus: 0)
    audioEngine.reset()
  }
  
  public func startSession(bufferSize: UInt32, sampleRate: Double, cb: @escaping (_ buffer: Array<Float>) -> Void) throws {
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
                          // Convert audio format from 44100Hz to passed sampleRate
                          // https://medium.com/@prianka.kariat/changing-the-format-of-ios-avaudioengine-mic-input-c183459cab63
                          let formatToConvert = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                                                sampleRate:   sampleRate,
                                                                channels:     1,
                                                                interleaved:  true)!
                          if buffer.format != formatToConvert {
                            var convertedBuffer: AVAudioPCMBuffer? = buffer
                            if let converter = AVAudioConverter(from: inputFormat, to: formatToConvert) {
                              convertedBuffer = AVAudioPCMBuffer(pcmFormat:  formatToConvert,
                                                                  frameCapacity: AVAudioFrameCount( formatToConvert.sampleRate * 0.4))
                              let inputBlock : AVAudioConverterInputBlock = { (inNumPackets, outStatus) -> AVAudioBuffer? in
                                outStatus.pointee = AVAudioConverterInputStatus.haveData
                                let audioBuffer : AVAudioBuffer = buffer
                                return audioBuffer
                              }
                              var error : NSError?
                              if let uwConvertedBuffer = convertedBuffer {
                                converter.convert(to: uwConvertedBuffer, error: &error, withInputFrom: inputBlock)
                                cb(Array(UnsafeBufferPointer(start: uwConvertedBuffer.floatChannelData![0], count:Int(uwConvertedBuffer.frameLength))))
                              }
                            }
                          } else {
                             cb(Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count:Int(buffer.frameLength))))
                          }
    }

    audioEngine.prepare()
    try audioEngine.start()
  }

  public func stopSession() throws {
    let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    audioEngine.stop()
    try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
  }
}
