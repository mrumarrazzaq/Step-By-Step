import 'dart:async';

class ACU {
  static final _instance = ACU._();

  bool _isRecording = false;

  ACU._();

  static get instance => _instance;

  Future<void> indicateRecordingStarted() async {
    _isRecording = true;
  }

  void indicateRecordingStoped() {
    _isRecording = false;
  }

  bool get isRecording => _isRecording;
}
