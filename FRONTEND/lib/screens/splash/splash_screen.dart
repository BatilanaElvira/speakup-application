import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';


class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _splashTimer;

  final List<Map<String, String>> _onboardingSlides = [
    {
      'image': 'assets/images/onboarding_illus_1.png',
      'title': 'Practice.\nImprove. Succeed.',
      'subtitle': 'AI feedback that helps you\nbecome a better speaker.',
      'buttonText': 'Next',
    },
    {
      'image': 'assets/images/onboarding_illus_2.png',
      'title': 'Personalized\nFeedback',
      'subtitle': 'Get detailed insights on your\nstrengths and areas to improve.',
      'buttonText': 'Next',
    },
    {
      'image': 'assets/images/onboarding_illus_3.png',
      'title': 'Track Your\nProgress',
      'subtitle': 'Follow your improvement\njourney step by step.',
      'buttonText': 'Get Started',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Splash screen auto-advance to Onboarding 1 after 3.5 seconds
    _splashTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted && _currentPage == 0) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    _splashTimer?.cancel();
    Provider.of<AppProvider>(context, listen: false).setSplashSeen();
    widget.onFinish();
  }

  void _onNextPressed() {
    _splashTimer?.cancel();
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentPage == 0 ? const Color(0xFF0F0C28) : Colors.white,
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          // 1. SPLASH SCREEN (Full Screen Logo, Tagline & Dual-tone Loading Bar)
          _buildSplashScreen(),

          // 2. ONBOARDING 1 (Practice. Improve. Succeed.)
          _buildOnboardingScreen(0),

          // 3. ONBOARDING 2 (Personalized Feedback)
          _buildOnboardingScreen(1),

          // 4. ONBOARDING 3 (Track Your Progress)
          _buildOnboardingScreen(2),
        ],
      ),
    );
  }

  /// Screen 1: Full-Screen Dark Splash with SpeakUp Logo
  Widget _buildSplashScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D0B24),
            Color(0xFF14103B),
            Color(0xFF1E1752),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Decorative background confetti / sparks
            Positioned(
              top: 60,
              left: 40,
              child: _buildConfettiDot(const Color(0xFF6366F1), 6),
            ),
            Positioned(
              top: 120,
              right: 60,
              child: _buildConfettiDot(const Color(0xFFFF9E7D), 8),
            ),
            Positioned(
              top: 240,
              left: 80,
              child: _buildConfettiDot(const Color(0xFFA78BFA), 5),
            ),
            Positioned(
              bottom: 180,
              right: 50,
              child: _buildConfettiDot(const Color(0xFFFF7A6B), 7),
            ),
            Positioned(
              bottom: 240,
              left: 50,
              child: _buildConfettiDot(const Color(0xFF818CF8), 6),
            ),

            // Top Skip Button
            Positioned(
              top: 16,
              right: 20,
              child: TextButton(
                onPressed: _finishOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'SKIP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Center Content: Logo, SpeakUp Title, Taglines & Dual Bar
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SpeakUp Logo Emblem
                    GestureDetector(
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF7A6B).withValues(alpha: 0.35),
                              blurRadius: 36,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/speakup_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFF1E1752),
                              child: const Icon(Icons.mic_rounded, size: 70, color: Color(0xFFFF7A6B)),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // SpeakUp Title
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Speak',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'Up',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF7A6B),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Tagline
                    const Text(
                      'Speak Confidently.\nBe Impactful.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFD4D0FC),
                        height: 1.35,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Bottom Dual-Tone Progress Pill
                    GestureDetector(
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 7,
                        decoration: BoxDecoration(
                          color: const Color(0xFF231C58),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 7,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF9E7D), Color(0xFFFF7A6B)],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF7A6B).withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Screen 2, 3, 4: Clean White Card Onboarding Screens (Matching Mockup)
  Widget _buildOnboardingScreen(int slideIndex) {
    final slide = _onboardingSlides[slideIndex];
    final isLastSlide = slideIndex == _onboardingSlides.length - 1;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECE8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.record_voice_over_rounded,
                          color: Color(0xFFFF7A6B),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'SpeakUp',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E1752),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        color: Color(0xFF8C88A8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Center Illustration + Text Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),

                    // Character Illustration
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 280,
                        maxWidth: 320,
                      ),
                      child: Image.asset(
                        slide['image']!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F2FD),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.image, size: 70, color: Color(0xFF6B46C1)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      slide['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A164B),
                        height: 1.25,
                        letterSpacing: -0.4,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      slide['subtitle']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757195),
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Indicator Dots (3 dots matching mockup)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (dotIndex) {
                final isActive = dotIndex == slideIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF38239C) : const Color(0xFFE2E0EE),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Bottom Action Button ('Next' or 'Get Started')
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isLastSlide
                        ? const LinearGradient(
                            colors: [Color(0xFFE54874), Color(0xFF8B2CB8)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF6342E8), Color(0xFF4328B7)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isLastSlide
                            ? const Color(0xFFE54874).withValues(alpha: 0.35)
                            : const Color(0xFF6342E8).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      slide['buttonText']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfettiDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.7),
        shape: BoxShape.circle,
      ),
    );
  }
}
