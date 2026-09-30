import 'package:flutter/material.dart';

class CameraFeedWidget extends StatelessWidget {
  final bool isFrontCamera;
  const CameraFeedWidget({super.key, this.isFrontCamera = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_rounded, color: Colors.white54, size: 56),
            SizedBox(height: 12),
            Text(
              'Camera connected',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
