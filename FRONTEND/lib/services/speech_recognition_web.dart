// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:js' as js;

class SpeechRecognitionImpl {
  static Timer? _pollTimer;

  static void startListening({
    required Function(String text, bool isFinal) onResult,
    Function(String error)? onError,
  }) {
    try {
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(milliseconds: 350), (_) {
        try {
          final t = js.context['_speakUpFullTranscript'];
          if (t != null && t.toString().trim().isNotEmpty) {
            onResult(t.toString().trim(), false);
          }
        } catch (_) {}
      });

      js.context['speakupOnSpeechResult'] = js.JsFunction.withThis((self, [dynamic text, dynamic isFinal]) {
        if (text != null) onResult(text.toString(), isFinal == true);
      });

      js.context['speakupOnSpeechError'] = js.JsFunction.withThis((self, [dynamic error]) {
        if (onError != null && error != null) onError(error.toString());
      });

      js.context.callMethod('eval', ["""
(function() {
  try {
    var SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRecognition) {
      console.warn('SpeechRecognition API not supported in this browser environment.');
      return;
    }

    if (window._speakUpRecognition) {
      try { window._speakUpRecognition.stop(); } catch(e) {}
    }

    var recognition = new SpeechRecognition();
    recognition.continuous = true;
    recognition.interimResults = true;
    recognition.lang = 'en-US';

    window._speakUpFullTranscript = '';
    window._speakUpRecordingActive = true;

    recognition.onresult = function(event) {
      var interim = '';
      for (var i = event.resultIndex; i < event.results.length; ++i) {
        if (event.results[i].isFinal) {
          window._speakUpFullTranscript += event.results[i][0].transcript + ' ';
        } else {
          interim += event.results[i][0].transcript;
        }
      }
      var combined = (window._speakUpFullTranscript + interim).trim();
      if (window.speakupOnSpeechResult) {
        window.speakupOnSpeechResult(combined, false);
      }
    };

    recognition.onerror = function(event) {
      console.warn('Speech recognition notice:', event.error);
      if (window.speakupOnSpeechError) {
        window.speakupOnSpeechError(event.error);
      }
    };

    recognition.onend = function() {
      if (window._speakUpRecordingActive) {
        try { recognition.start(); } catch(e) {}
      }
    };

    recognition.start();
    window._speakUpRecognition = recognition;
  } catch(err) {
    console.warn('Speech recognition startup caught:', err);
  }
})();
"""]);
    } catch (_) {}
  }

  static String stopListening() {
    _pollTimer?.cancel();
    try {
      js.context.callMethod('eval', ["""
(function() {
  try {
    window._speakUpRecordingActive = false;
    if (window._speakUpRecognition) {
      window._speakUpRecognition.stop();
      window._speakUpRecognition = null;
    }
  } catch(e) {}
})();
"""]);
      final transcript = js.context['_speakUpFullTranscript'];
      return transcript != null ? transcript.toString().trim() : '';
    } catch (_) {
      return '';
    }
  }

  /// Text-To-Speech: Evaluator speaks question out loud to user
  static void speakText(String text, {double rate = 1.0, double pitch = 1.0}) {
    try {
      final safeText = text.replaceAll('"', '\\"').replaceAll('\n', ' ');
      js.context.callMethod('eval', ["""
(function() {
  try {
    if (!('speechSynthesis' in window)) return;
    window.speechSynthesis.cancel();
    var utterance = new SpeechSynthesisUtterance("$safeText");
    utterance.rate = $rate;
    utterance.pitch = $pitch;
    utterance.lang = 'en-US';
    window.speechSynthesis.speak(utterance);
  } catch(e) {}
})();
"""]);
    } catch (_) {}
  }

  static void stopSpeaking() {
    try {
      js.context.callMethod('eval', ["""
(function() {
  try {
    if ('speechSynthesis' in window) {
      window.speechSynthesis.cancel();
    }
  } catch(e) {}
})();
"""]);
    } catch (_) {}
  }
}
