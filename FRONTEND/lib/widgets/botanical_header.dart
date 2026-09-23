import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BotanicalHeaderDecoration extends StatelessWidget {
  final Widget child;
  final bool showLeaves;

  const BotanicalHeaderDecoration({
    super.key,
    required this.child,
    this.showLeaves = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showLeaves)
          Positioned(
            top: -10,
            right: -10,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.85,
                child: CustomPaint(
                  size: const Size(90, 90),
                  painter: _BotanicalLeafPainter(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BotanicalLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = AppColors.sageGreen.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final stemPaint = Paint()
      ..color = AppColors.sageGreen.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final petalPaint = Paint()
      ..color = AppColors.primaryCoral.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    // Soft botanical stem line
    final stemPath = Path()
      ..moveTo(size.width, 0)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.2, size.height * 0.9);
    canvas.drawPath(stemPath, stemPaint);

    // Leaves along stem
    canvas.save();
    canvas.translate(size.width * 0.6, size.height * 0.3);
    canvas.rotate(-0.6);
    canvas.drawOval(const Rect.fromLTWH(0, 0, 16, 8), leafPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(size.width * 0.4, size.height * 0.55);
    canvas.rotate(0.5);
    canvas.drawOval(const Rect.fromLTWH(0, 0, 18, 9), leafPaint);
    canvas.restore();

    // Soft flower accent
    canvas.save();
    canvas.translate(size.width * 0.75, size.height * 0.15);
    canvas.drawCircle(const Offset(0, 0), 6, petalPaint);
    canvas.drawCircle(const Offset(6, 4), 5, petalPaint);
    canvas.drawCircle(const Offset(-4, 5), 5, petalPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
