import 'package:audio_waveforms/audio_waveforms.dart';

class RecordManager{
  late final RecorderController recorderController;
  String? recordingPath;

  void initialiseController() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 16000;
  }


}