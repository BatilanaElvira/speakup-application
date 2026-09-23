import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (Vibrant Purple & Warm Coral Aesthetic)
  static const Color primaryPurple = Color(0xFF5F45FD);
  static const Color primaryBlue = Color(0xFF5F45FD); // Primary brand violet purple
  static const Color primaryCoral = Color(0xFFFF5666); // Warm coral red for CTAs
  static const Color secondaryTeal = Color(0xFF00C48C); // Emerald Green
  static const Color motivationCoral = Color(0xFFFF5666);

  // Background & Containers
  static const Color background = Color(0xFFF7F8FC); // Soft lavender-tinted background
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFEFF1F9);
  static const Color cardBorder = Color(0xFFECECFD);

  // Emerald Green Accents
  static const Color sageGreen = Color(0xFF00C48C);
  static const Color sageLightBg = Color(0xFFE6F9F3);

  // Text Colors
  static const Color mainText = Color(0xFF181830);
  static const Color secondaryText = Color(0xFF6E6E8D);
  static const Color lightText = Color(0xFFA0A0C0);

  // Status & Feedback Colors
  static const Color successGreen = Color(0xFF00C48C);
  static const Color warningAmber = Color(0xFFFFB800);
  static const Color errorRed = Color(0xFFFF4D4D);

  // Dark Mode (Splash & Recording Studio)
  static const Color darkBackground = Color(0xFF0D0B26);

  // Accent Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5F45FD), Color(0xFF7A61FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF5F45FD), Color(0xFF7A61FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coralGradient = LinearGradient(
    colors: [Color(0xFFFF5666), Color(0xFFFF7A6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF00C48C), Color(0xFF26E3AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF7F8FC), Color(0xFFEFF1F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1B164C), Color(0xFF0D0B26)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Subtle Violet Box Shadow
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0x0C5F45FD),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

