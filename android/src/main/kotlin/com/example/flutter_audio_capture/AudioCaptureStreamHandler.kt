package com.example.flutter_audio_capture

import java.nio.ByteBuffer
import java.nio.ByteOrder

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.util.Log
import android.os.Handler
import android.os.Looper

import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.EventChannel.EventSink
import java.lang.Exception

public class AudioCaptureStreamHandler: StreamHandler {
    public val eventChannelName = "ymd.dev/audio_capture_event_channnel"
    private val SAMPLE_RATE: Int = 16000
    private val TAG: String = "AudioCaptureStream"
    private var isCapturing: Boolean = false
    private var listener = null
    private var thread: Thread? = null
    private var _events: EventSink? = null
    private val uiThreadHandler: Handler = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventSink?) {
      Log.d(TAG, "onListen started")
      this._events = events
    }

    override fun onCancel(p0: Any?) {
      Log.d(TAG, "onListen canceled")
    }

    public fun startRecording() {
        if (thread != null) return

        isCapturing = true
        val runnableObj: Runnable = object: Runnable {
          override public fun run() {
              record()
          }
        }
        thread = Thread(runnableObj)
        thread?.start()
    }

    public fun stopRecording() {
        if (thread == null) return
        isCapturing = false
        thread = null
    }

    private fun record() {
        android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_AUDIO)

        // Buffer size in bytes: for 0.1 second of audio
        var bufferSize: Int = (SAMPLE_RATE * 0.1 * 2).toInt()
        if (bufferSize == AudioRecord.ERROR || bufferSize == AudioRecord.ERROR_BAD_VALUE) {
            bufferSize = SAMPLE_RATE * 2
        }

        val audioBuffer: FloatArray = FloatArray(bufferSize)
        val record: AudioRecord = AudioRecord.Builder()
                        .setAudioSource(MediaRecorder.AudioSource.DEFAULT)
                        .setAudioFormat(
                          AudioFormat.Builder()
                            .setEncoding(AudioFormat.ENCODING_PCM_FLOAT)
                            .setSampleRate(SAMPLE_RATE)
                            .setChannelMask(AudioFormat.CHANNEL_IN_MONO)
                            .build()
                        )
                        .setBufferSizeInBytes(bufferSize)
                        .build()

        if (record.getState() != AudioRecord.STATE_INITIALIZED) {
            _events?.error("AUDIO_RECORD_INITIALIZE_ERROR", "AudioRecord can't initialize", null)
        }

        record.startRecording()
        while (isCapturing) {
            try {
                record.read(audioBuffer, 0, audioBuffer.size, AudioRecord.READ_BLOCKING)
            } catch (e: Exception) {
                Log.d(TAG, e.toString())
            }

            uiThreadHandler.post(object: Runnable {
                override fun run() {
                    if (isCapturing) {
                        _events?.success(audioBuffer.toList())
                    }
                }
            })
        }

        record.stop()
        record.release()
    }
}
