// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class CrowdAudioImpl {
  /// Starts realistic continuous ambient room acoustics (low hum, air resonance & subtle audience presence)
  static void startAmbientNoise(double volume) {
    try {
      final vol = volume.clamp(0.0, 1.0);
      js.context.callMethod('eval', ["""
(function() {
  try {
    var AudioCtx = window.AudioContext || window.webkitAudioContext;
    if (!AudioCtx) return;
    window._speakUpAudioCtx = window._speakUpAudioCtx || new AudioCtx();
    var ctx = window._speakUpAudioCtx;
    if (ctx.state === 'suspended') ctx.resume();

    if (window._speakUpAmbientNode) {
      try { window._speakUpAmbientNode.stop(); } catch(e) {}
    }

    var bufferSize = ctx.sampleRate * 3;
    var buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
    var data = buffer.getChannelData(0);
    var lastOut = 0.0;
    for (var i = 0; i < bufferSize; i++) {
      var white = Math.random() * 2 - 1;
      data[i] = (lastOut + (0.02 * white)) / 1.02;
      lastOut = data[i];
    }

    var ambientSource = ctx.createBufferSource();
    ambientSource.buffer = buffer;
    ambientSource.loop = true;

    var filter = ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.value = 350;

    var gain = ctx.createGain();
    gain.gain.value = $vol * 0.30;

    ambientSource.connect(filter);
    filter.connect(gain);
    gain.connect(ctx.destination);
    ambientSource.start();

    window._speakUpAmbientNode = ambientSource;
    window._speakUpAmbientGain = gain;
  } catch(e) {}
})();
"""]);
    } catch (_) {}
  }

  /// Stops continuous ambient room noise
  static void stopAmbientNoise() {
    try {
      js.context.callMethod('eval', ["""
(function() {
  try {
    if (window._speakUpAmbientNode) {
      window._speakUpAmbientNode.stop();
      window._speakUpAmbientNode = null;
    }
  } catch(e) {}
})();
"""]);
    } catch (_) {}
  }

  /// Synthesizes realistic auditorium applause with high-impact handclaps
  static void playApplause(double volume) {
    try {
      final vol = volume.clamp(0.0, 1.0);
      if (vol <= 0.01) return;

      js.context.callMethod('eval', ["""
(function() {
  try {
    var AudioCtx = window.AudioContext || window.webkitAudioContext;
    if (!AudioCtx) return;
    window._speakUpAudioCtx = window._speakUpAudioCtx || new AudioCtx();
    var ctx = window._speakUpAudioCtx;
    if (ctx.state === 'suspended') ctx.resume();

    var duration = 2.8;
    var bufferSize = Math.floor(ctx.sampleRate * duration);
    var buffer = ctx.createBuffer(2, bufferSize, ctx.sampleRate);
    var left = buffer.getChannelData(0);
    var right = buffer.getChannelData(1);

    for (var i = 0; i < bufferSize; i++) {
      var t = i / bufferSize;
      var env = Math.pow(Math.sin(t * Math.PI), 0.7);
      var clapLeft = (Math.random() < 0.06) ? (Math.random() * 2 - 1) * 2.2 : 0;
      var clapRight = (Math.random() < 0.06) ? (Math.random() * 2 - 1) * 2.2 : 0;
      var wash = (Math.random() * 2 - 1) * 0.5;
      left[i] = (wash + clapLeft) * env;
      right[i] = (wash + clapRight) * env;
    }

    var noise = ctx.createBufferSource();
    noise.buffer = buffer;

    var filter = ctx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.value = 1400;
    filter.Q.value = 1.0;

    var gain = ctx.createGain();
    gain.gain.value = $vol * 0.65;

    noise.connect(filter);
    filter.connect(gain);
    gain.connect(ctx.destination);
    noise.start();
  } catch(e) {}
})();
"""]);
    } catch (_) {}
  }

  /// Synthesizes ambient audience murmurs (low frequency chatter wash)
  static void playMurmur(double volume) {
    try {
      final vol = volume.clamp(0.0, 1.0);
      if (vol <= 0.01) return;

      js.context.callMethod('eval', ["""
(function() {
  try {
    var AudioCtx = window.AudioContext || window.webkitAudioContext;
    if (!AudioCtx) return;
    window._speakUpAudioCtx = window._speakUpAudioCtx || new AudioCtx();
    var ctx = window._speakUpAudioCtx;
    if (ctx.state === 'suspended') ctx.resume();

    var bufferSize = Math.floor(ctx.sampleRate * 2.2);
    var buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
    var data = buffer.getChannelData(0);
    for (var i = 0; i < bufferSize; i++) {
      var t = i / bufferSize;
      var env = Math.sin(t * Math.PI);
      data[i] = (Math.random() * 2 - 1) * 0.75 * env;
    }
    var noise = ctx.createBufferSource();
    noise.buffer = buffer;

    var filter = ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.value = 520;

    var gain = ctx.createGain();
    gain.gain.value = $vol * 0.50;

    noise.connect(filter);
    filter.connect(gain);
    gain.connect(ctx.destination);
    noise.start();
  } catch(e) {}
})();
"""]);
    } catch (_) {}
  }

  /// Soft pleasant chime or gavel attention tap when audience focuses in silence
  static void playChime(double volume) {
    try {
      final vol = volume.clamp(0.0, 1.0);
      if (vol <= 0.01) return;

      js.context.callMethod('eval', ["""
(function() {
  try {
    var AudioCtx = window.AudioContext || window.webkitAudioContext;
    if (!AudioCtx) return;
    window._speakUpAudioCtx = window._speakUpAudioCtx || new AudioCtx();
    var ctx = window._speakUpAudioCtx;
    if (ctx.state === 'suspended') ctx.resume();

    var osc = ctx.createOscillator();
    var gain = ctx.createGain();
    osc.type = 'sine';
    osc.frequency.value = 880;

    var now = ctx.currentTime;
    gain.gain.setValueAtTime($vol * 0.35, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.9);

    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start();
    osc.stop(now + 0.9);
  } catch(e) {}
})();
"""]);
    } catch (_) {}
  }

  /// Celebratory audience cheer & ovation
  static void playCheer(double volume) {
    try {
      final vol = volume.clamp(0.0, 1.0);
      if (vol <= 0.01) return;

      js.context.callMethod('eval', ["""
(function() {
  try {
    var AudioCtx = window.AudioContext || window.webkitAudioContext;
    if (!AudioCtx) return;
    window._speakUpAudioCtx = window._speakUpAudioCtx || new AudioCtx();
    var ctx = window._speakUpAudioCtx;
    if (ctx.state === 'suspended') ctx.resume();

    var duration = 2.0;
    var bufferSize = Math.floor(ctx.sampleRate * duration);
    var buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
    var data = buffer.getChannelData(0);
    for (var i = 0; i < bufferSize; i++) {
      var t = i / bufferSize;
      var env = Math.pow(Math.sin(t * Math.PI), 0.5);
      data[i] = (Math.random() * 2 - 1) * 0.9 * env;
    }
    var noise = ctx.createBufferSource();
    noise.buffer = buffer;

    var filter = ctx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.value = 950;
    filter.Q.value = 2.0;

    var gain = ctx.createGain();
    gain.gain.value = $vol * 0.55;

    noise.connect(filter);
    filter.connect(gain);
    gain.connect(ctx.destination);
    noise.start();
  } catch(e) {}
})();
"""]);
    } catch (_) {}
  }

  /// Nodding mimic sound: subtle vocal agreement / "mm-hmm" room assent
  static void playNodMimic(double volume) {
    try {
      final vol = volume.clamp(0.0, 1.0);
      if (vol <= 0.01) return;

      js.context.callMethod('eval', ["""
(function() {
  try {
    var AudioCtx = window.AudioContext || window.webkitAudioContext;
    if (!AudioCtx) return;
    window._speakUpAudioCtx = window._speakUpAudioCtx || new AudioCtx();
    var ctx = window._speakUpAudioCtx;
    if (ctx.state === 'suspended') ctx.resume();

    var osc = ctx.createOscillator();
    var gain = ctx.createGain();
    osc.type = 'triangle';
    var now = ctx.currentTime;
    osc.frequency.setValueAtTime(140, now);
    osc.frequency.exponentialRampToValueAtTime(185, now + 0.15);
    osc.frequency.exponentialRampToValueAtTime(160, now + 0.35);

    gain.gain.setValueAtTime(0.001, now);
    gain.gain.exponentialRampToValueAtTime($vol * 0.35, now + 0.08);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.40);

    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start(now);
    osc.stop(now + 0.45);
  } catch(e) {}
})();
"""]);
    } catch (_) {}
  }
}
