import Flutter
import UIKit

public class SwiftFlutterAudioCapturePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = AudioCaptureEventStreamHandler()
    FlutterEventChannel(name: instance.eventChannelName, binaryMessenger: registrar.messenger()).setStreamHandler(instance)
  }
}
