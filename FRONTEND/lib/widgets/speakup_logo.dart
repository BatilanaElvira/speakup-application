import 'package:flutter/material.dart';

class SpeakUpLogoWidget extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool isLightMode;
  final bool roundedCard;

  const SpeakUpLogoWidget({
    super.key,
    this.size = 120,
    this.showTagline = true,
    this.isLightMode = true,
    this.roundedCard = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B26),
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5F45FD).withValues(alpha: 0.25),
            blurRadius: size * 0.15,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: Image.asset(
          'assets/images/speakup_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/speakup_logo.jpg',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
