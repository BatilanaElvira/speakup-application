class SpeechRecognitionImpl {
  static void startListening({
    required Function(String text, bool isFinal) onResult,
    Function(String error)? onError,
  }) {}

  static String stopListening() {
    return '';
  }

  static void speakText(String text, {double rate = 1.0, double pitch = 1.0}) {}

  static void stopSpeaking() {}
}
