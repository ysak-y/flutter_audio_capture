class IAudioCapture {
  Future<void> start(Function listener, Function onError,
      {int sampleRate = 44000, int bufferSize = 5000}) async {
    throw UnimplementedError();
  }

  Future<void> stop() async {
    throw UnimplementedError();
  }
}
