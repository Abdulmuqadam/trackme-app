import 'package:audio_waveforms/audio_waveforms.dart';

class RecordManager {
  late final RecorderController recorderController;
  String? recordingPath;

  void initialiseController() {
    recorderController = RecorderController();
  }
}
