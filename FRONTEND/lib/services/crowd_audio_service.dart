import 'crowd_audio_stub.dart'
    if (dart.library.html) 'crowd_audio_web.dart';

class CrowdAudioService {
  static void startAmbientNoise([double volume = 0.6]) {
    CrowdAudioImpl.startAmbientNoise(volume);
  }

  static void stopAmbientNoise() {
    CrowdAudioImpl.stopAmbientNoise();
  }

  static void playApplause([double volume = 0.85]) {
    CrowdAudioImpl.playApplause(volume);
  }

  static void playMurmur([double volume = 0.8]) {
    CrowdAudioImpl.playMurmur(volume);
  }

  static void playSilenceChime([double volume = 0.75]) {
    CrowdAudioImpl.playChime(volume);
  }

  static void playCheer([double volume = 0.85]) {
    CrowdAudioImpl.playCheer(volume);
  }

  static void playNodMimic([double volume = 0.8]) {
    CrowdAudioImpl.playNodMimic(volume);
  }
}
