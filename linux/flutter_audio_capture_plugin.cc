#include "include/flutter_audio_capture/flutter_audio_capture_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>
#include <iostream>
#include <thread>
#include <stdexcept>
#include <stdio.h>
#include <string>


#define FLUTTER_AUDIO_CAPTURE_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_audio_capture_plugin_get_type(), \
                              FlutterAudioCapturePlugin))

const char kMethodChannel[] = "ymd.dev/audio_capture_event_channel/method_channel";
const char kEventChannel[] = "ymd.dev/audio_capture_event_channel";

struct _FlutterAudioCapturePlugin {
  GObject parent_instance;
  FlEventChannel* event_channel;
};

G_DEFINE_TYPE(FlutterAudioCapturePlugin, flutter_audio_capture_plugin, g_object_get_type())


///
// event channel & audio recording
///

static volatile bool is_recording = false;
static std::thread* thread = nullptr;

static void event_channel_send_data(double * samples, int num_samples, FlEventChannel* channel) {
  g_autoptr(FlValue) event = fl_value_new_float_list(samples, num_samples);
  fl_event_channel_send(channel, event, nullptr, nullptr);
}

void recorder_thread(const std::string cmd, int num_samples, FlEventChannel* channel) {
  FILE* pipe = popen(cmd.c_str(), "r");
  int16_t raw_samples[num_samples];
  double * samples = (double *) malloc(num_samples * sizeof(double));
  if (!pipe) throw std::runtime_error("popen() failed!");
  try {
    while (is_recording) {
      size_t read = fread(raw_samples, sizeof(int16_t), num_samples, pipe);

      // convert
      for (int i = 0; i < read; i++) {
        samples[i] = ((double) raw_samples[i]) * 1e-4;
      }

      // send
      event_channel_send_data(samples, read, channel);
    }
  } catch (...) {
    pclose(pipe);
    delete samples;
    throw;
  }
  delete samples;
  pclose(pipe);
}

static FlMethodErrorResponse* event_channel_listen_cb(FlEventChannel* channel,
                                                      FlValue* args,
                                                      gpointer user_data) {
  // extract args
  FlValue* fl_sr = fl_value_lookup_string(args, "sampleRate");
  int sr = fl_value_get_int(fl_sr);
  FlValue* fl_bs = fl_value_lookup_string(args, "bufferSize");
  int bs = fl_value_get_int(fl_bs);
  char cmd [128];
  int n = sprintf(cmd, "parec -r --rate=%d --format=s16le --channels=1", sr);
  cmd[n] = '\0';

  // start recording
  g_print("Starting recording sr=%d, bs=%d\n", sr, bs);
  is_recording = true;
  std::string command(cmd);
  thread = new std::thread(recorder_thread, command, bs, channel);
  return NULL;
}

static FlMethodErrorResponse* event_channel_cancel_cb(FlEventChannel* channel,
                                                      FlValue* args,
                                                      gpointer user_data) {
  // join & cleanup thread
  //  (is_recording acts as a signal mechanism here)
  is_recording = false;
  if (thread != nullptr) {
    thread->join();
    delete thread;
  }
  return NULL;
}


///
// plugin plumbing
///

// Called when a method call is received from Flutter.
static void flutter_audio_capture_plugin_handle_method_call(
    FlutterAudioCapturePlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  // getPlatformVersion
  if (strcmp(method, "getPlatformVersion") == 0) {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void flutter_audio_capture_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(flutter_audio_capture_plugin_parent_class)->dispose(object);
}

static void flutter_audio_capture_plugin_class_init(FlutterAudioCapturePluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = flutter_audio_capture_plugin_dispose;
}

static void flutter_audio_capture_plugin_init(FlutterAudioCapturePlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  FlutterAudioCapturePlugin* plugin = FLUTTER_AUDIO_CAPTURE_PLUGIN(user_data);
  flutter_audio_capture_plugin_handle_method_call(plugin, method_call);
}

void flutter_audio_capture_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlutterAudioCapturePlugin* plugin = FLUTTER_AUDIO_CAPTURE_PLUGIN(
      g_object_new(flutter_audio_capture_plugin_get_type(), nullptr));

  // register method calls (not used here)
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            kMethodChannel,
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  // register event channel
  //  (usable from Dart)
  plugin->event_channel = fl_event_channel_new(
      fl_plugin_registrar_get_messenger(registrar),
      kEventChannel,
      FL_METHOD_CODEC(codec));
  fl_event_channel_set_stream_handlers(
      plugin->event_channel, event_channel_listen_cb, event_channel_cancel_cb,
      nullptr, nullptr);

  g_object_unref(plugin);
}

