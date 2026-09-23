import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AudioWaveVisualizer extends StatefulWidget {
  final bool isRecording;
  final Color barColor;

  const AudioWaveVisualizer({
    super.key,
    required this.isRecording,
    this.barColor = AppColors.primaryBlue,
  });

  @override
  State<AudioWaveVisualizer> createState() => _AudioWaveVisualizerState();
}

class _AudioWaveVisualizerState extends State<AudioWaveVisualizer> {
  Timer? _timer;
  final List<double> _barHeights = List.generate(24, (index) => 12.0);
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    if (widget.isRecording) {
      _startAnim();
    }
  }

  @override
  void didUpdateWidget(AudioWaveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _startAnim();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _stopAnim();
    }
  }

  void _startAnim() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        for (int i = 0; i < _barHeights.length; i++) {
          _barHeights[i] = 8.0 + _random.nextDouble() * 45.0;
        }
      });
    });
  }

  void _stopAnim() {
    _timer?.cancel();
    setState(() {
      for (int i = 0; i < _barHeights.length; i++) {
        _barHeights[i] = 10.0;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _barHeights.map((height) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            width: 4,
            height: widget.isRecording ? height : 10,
            decoration: BoxDecoration(
              color: widget.isRecording ? widget.barColor : AppColors.cardBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }).toList(),
      ),
    );
  }
}
