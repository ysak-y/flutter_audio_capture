import Flutter
import UIKit

public class SwiftFlutterAudioCapturePlugin: NSObject, FlutterPlugin {
    var instance: AudioCaptureEventStreamHandler

    init(instance: AudioCaptureEventStreamHandler){
        self.instance = instance
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannelName = "ymd.dev/audio_capture_method_channel"
        let instance = AudioCaptureEventStreamHandler()

        FlutterEventChannel(name: instance.eventChannelName, binaryMessenger: registrar.messenger()).setStreamHandler(instance)

        let methodChannel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(SwiftFlutterAudioCapturePlugin(instance: instance), channel: methodChannel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getSampleRate":
            result(instance.actualSampleRate)
        case "init":
            do {
                result(try instance.setup())
            } catch {
                result(FlutterError(code: "initFailed", message: "Error occured in init", details: error.localizedDescription))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}