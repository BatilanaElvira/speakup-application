// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class CameraFeedWidget extends StatefulWidget {
  final bool isFrontCamera;
  const CameraFeedWidget({super.key, this.isFrontCamera = true});

  @override
  State<CameraFeedWidget> createState() => _CameraFeedWidgetState();
}

class _CameraFeedWidgetState extends State<CameraFeedWidget> {
  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;
  String? _errorMessage;
  final String _viewId = 'speakup-camera-feed-view';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() {
    _videoElement = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.transform = widget.isFrontCamera ? 'scaleX(-1)' : 'none';

    // Register web view factory
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) => _videoElement!,
    );

    _startStream();
  }

  Future<void> _startStream() async {
    try {
      final constraints = {
        'video': {
          'facingMode': widget.isFrontCamera ? 'user' : 'environment',
          'width': {'ideal': 1280},
          'height': {'ideal': 720}
        },
        'audio': false
      };

      final stream = await html.window.navigator.mediaDevices?.getUserMedia(constraints);
      if (stream != null) {
        _mediaStream = stream;
        _videoElement?.srcObject = stream;
        _videoElement?.play();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Camera access: $e';
        });
      }
    }
  }

  @override
  void didUpdateWidget(CameraFeedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFrontCamera != widget.isFrontCamera) {
      _videoElement?.style.transform = widget.isFrontCamera ? 'scaleX(-1)' : 'none';
      _stopStream();
      _startStream();
    }
  }

  void _stopStream() {
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _mediaStream = null;
  }

  @override
  void dispose() {
    _stopStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              Text(
                'Camera inactive: $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return HtmlElementView(viewType: _viewId);
  }
}
