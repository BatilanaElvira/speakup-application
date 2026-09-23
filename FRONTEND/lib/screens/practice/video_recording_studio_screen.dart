import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../analysis/analysis_report_screen.dart';

class VideoRecordingStudioScreen extends StatefulWidget {
  final String? nodeId;

  const VideoRecordingStudioScreen({super.key, this.nodeId});

  @override
  State<VideoRecordingStudioScreen> createState() => _VideoRecordingStudioScreenState();
}

class _VideoRecordingStudioScreenState extends State<VideoRecordingStudioScreen> {
  Timer? _timer;
  int _seconds = 0; // Starts from 00:00:00
  bool _isRecording = false;
  bool _isPaused = false;
  bool _showGridLines = true;
  bool _isFrontCamera = true;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isPaused = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _stopAndAnalyze() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AnalysisReportScreen()),
    );
  }

  String _formatTimer(int sec) {
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    final s = sec % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate camera background
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Simulated Live Video Camera Viewport
            Positioned.fill(
              child: Container(
                color: const Color(0xFF1E293B),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Simulated video feed avatar silhouette / face position guide
                    Opacity(
                      opacity: 0.15,
                      child: Container(
                        width: 240,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.person_rounded, size: 160, color: Colors.white),
                      ),
                    ),

                    // Grid Lines Overlay
                    if (_showGridLines) ...[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Divider(color: Colors.white12, height: 1),
                          Divider(color: Colors.white12, height: 1),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          VerticalDivider(color: Colors.white12, width: 1),
                          VerticalDivider(color: Colors.white12, width: 1),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 2. Top Controls & Live Status Header
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Timer Pill (00:00:00)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isRecording ? AppColors.primaryCoral : Colors.white24,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording ? AppColors.primaryCoral : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimer(_seconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Camera options (Flip & Grid toggle)
                  Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                          child: Icon(
                            _showGridLines ? Icons.grid_on_rounded : Icons.grid_off_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showGridLines = !_showGridLines;
                          });
                        },
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                          child: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 18),
                        ),
                        onPressed: () {
                          setState(() {
                            _isFrontCamera = !_isFrontCamera;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Bottom Video Recording Controls (Start, Pause, Stop)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  if (!_isRecording) ...[
                    const Text(
                      'Ready to Record Video',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _startRecording,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryCoral,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryCoral.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 36),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Start Recording', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Pause / Resume Button
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              iconSize: 32,
                              icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: Icon(
                                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: _togglePause,
                            ),
                            Text(
                              _isPaused ? 'Resume' : 'Pause',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),

                        // Stop & Analyze Button (Red Square inside circle)
                        GestureDetector(
                          onTap: _stopAndAnalyze,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              color: AppColors.primaryCoral,
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        // Retake / Reset Button
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              iconSize: 32,
                              icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.refresh_rounded, color: Colors.white),
                              ),
                              onPressed: () {
                                setState(() {
                                  _seconds = 0;
                                  _isPaused = false;
                                });
                              },
                            ),
                            const Text('Retake', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
