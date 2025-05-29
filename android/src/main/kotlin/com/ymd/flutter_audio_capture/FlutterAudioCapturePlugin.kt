package com.ymd.flutter_audio_capture

import android.util.Log
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterAudioCapturePlugin */
public class FlutterAudioCapturePlugin: FlutterPlugin, MethodCallHandler {
  private val methodChannelName = "ymd.dev/audio_capture_method_channel"
  private val audioCaptureStreamHandler: AudioCaptureStreamHandler = AudioCaptureStreamHandler()
  private val TAG: String = "FlutterAudioCapture"

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val messenger = flutterPluginBinding.getBinaryMessenger()
    EventChannel(messenger, this.audioCaptureStreamHandler.eventChannelName).setStreamHandler(this.audioCaptureStreamHandler)
    MethodChannel(messenger, methodChannelName).setMethodCallHandler(this)
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "init" -> {
        // For now, we do nothing to init on android
        result.success(true)
      }
      "getSampleRate" -> {
        result.success(this.audioCaptureStreamHandler.actualSampleRate.toDouble())
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
