import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioManager {
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordingPath;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }


  Future<String?> startRecording() async {
    if (await hasPermission()) {
      try {
        _recordingPath = await tempFilePath();
        await _recorder.start(const RecordConfig(), path: _recordingPath!);
        return _recordingPath;
      } catch (e) {
        if (kDebugMode) {
          print('Error starting recording: $e');
        }
        return null;
      }
    } else {
      if (kDebugMode) {
        print('Permission not granted for recording.');
      }
      return null;
    }
  }

  Future<String?> getRecordingPath() async {
    return _recordingPath;
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      return path;
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping recording: $e');
      }
      return null;
    }
  }

  void dispose() {
    _recorder.dispose();
  }

  Future<String> tempFilePath() async {
    final cacheDir = await getApplicationDocumentsDirectory();
    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
    final filePath = '${cacheDir.path}/$fileName';

    return filePath;
  }
}
