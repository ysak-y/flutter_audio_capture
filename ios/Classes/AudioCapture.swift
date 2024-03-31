import Foundation
import AVFoundation

public class AudioCapture {
  let audioEngine: AVAudioEngine = AVAudioEngine()
    private var outputFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16, sampleRate: 44100, channels: 2, interleaved: true)
  init() {
      do{
    let audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    try audioSession.setCategory(AVAudioSession.Category.playAndRecord,
                                  mode: AVAudioSession.Mode.default,
                                 options: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP, .allowAirPlay, .allowBluetooth])
    try audioSession.setActive(true)
      }
      catch let err {
          print(err)
      }
  }
  
  deinit{
    audioEngine.inputNode.removeTap(onBus: 0)
    audioEngine.stop()
  }
  
  public func startSession(bufferSize: UInt32, sampleRate: Double, cb: @escaping (_ buffer: Array<Float>) -> Void) throws {
  
    let inputNode = audioEngine.inputNode
    let inputFormat  = inputNode.inputFormat(forBus: 0)
    // try! audioEngine.start()
    do {
      try audioEngine.start()
    } catch {
      print("Error starting audio engine: \(error)")
      return
    }
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
                                                                  // frameCapacity: AVAudioFrameCount( formatToConvert.sampleRate * 0.4))
                                                                  frameCapacity: AVAudioFrameCount(self.outputFormat!.sampleRate) * buffer.frameLength / AVAudioFrameCount(buffer.format.sampleRate))
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
          
  }

  public func stopSession() throws {
    audioEngine.inputNode.removeTap(onBus: 0)
    audioEngine.stop()
  }
}
