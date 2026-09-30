import 'speech_recognition_stub.dart'
    if (dart.library.html) 'speech_recognition_web.dart';

class SpeechRecognitionService {
  static void startListening({
    required Function(String text, bool isFinal) onResult,
    Function(String error)? onError,
  }) {
    SpeechRecognitionImpl.startListening(onResult: onResult, onError: onError);
  }

  static String stopListening() {
    return SpeechRecognitionImpl.stopListening();
  }

  static void speakText(String text, {double rate = 1.0, double pitch = 1.0}) {
    SpeechRecognitionImpl.speakText(text, rate: rate, pitch: pitch);
  }

  static void stopSpeaking() {
    SpeechRecognitionImpl.stopSpeaking();
  }
}
