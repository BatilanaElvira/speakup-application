import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/simulated_environment.dart';

class SimulatedEnvironmentBackdrop extends StatefulWidget {
  final SimulatedEnvironment environment;
  final bool isRecording;
  final bool isEnabled;

  const SimulatedEnvironmentBackdrop({
    super.key,
    required this.environment,
    this.isRecording = false,
    this.isEnabled = true,
  });

  @override
  State<SimulatedEnvironmentBackdrop> createState() => _SimulatedEnvironmentBackdropState();
}

class _SimulatedEnvironmentBackdropState extends State<SimulatedEnvironmentBackdrop>
    with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return Container(
        color: const Color(0xFF0F172A),
        child: const Center(
          child: Icon(Icons.mic_none_rounded, size: 120, color: Colors.white10),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, child) {
        final animVal = _ambientController.value;
        return Stack(
          children: [
            // 1. Base Environment Scenery
            Positioned.fill(
              child: _buildEnvironmentScene(widget.environment.id, animVal),
            ),

            // 2. Animated Ambient Lighting & Beams
            Positioned.fill(
              child: _buildLightingEffects(widget.environment.id, animVal),
            ),

            // 3. Dynamic Crowd / Audience Silhouettes
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 190,
              child: _buildCrowdSilhouettes(widget.environment.id, animVal),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnvironmentScene(String envId, double anim) {
    switch (envId) {
      case 'auditorium':
      case 'tedx_stage':
        return Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, 0.2),
              radius: 1.2,
              colors: [
                Color(0xFF4A0A17), // Warm deep crimson stage glow
                Color(0xFF200309),
                Color(0xFF0A0103),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Red circular stage carpet (TED hallmark)
              Positioned(
                bottom: 80,
                left: 40,
                right: 40,
                height: 130,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.elliptical(300, 130)),
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFE50914).withValues(alpha: 0.65 + anim * 0.15),
                        const Color(0xFF8B0000).withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Stage backdrop letters "TEDx" subtle glow
              Positioned(
                top: 70,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'TEDx AUDITORIUM',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6.0,
                      color: const Color(0xFFE50914).withValues(alpha: 0.35 + anim * 0.1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'boardroom':
      case 'meeting_room':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
                Color(0xFF0B0F19),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Corporate Skyline Window (Night city skyline silhouettes)
              Positioned(
                top: 40,
                left: 20,
                right: 20,
                height: 220,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0B1930), Color(0xFF1E3A5F)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // City lights
                      ...List.generate(12, (i) {
                        final left = 16.0 + i * 26.0;
                        final height = 40.0 + (i * 17) % 90;
                        return Positioned(
                          bottom: 0,
                          left: left,
                          width: 22,
                          height: height,
                          child: Container(
                            color: const Color(0xFF0A1120),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                4,
                                (j) => Container(
                                  width: 4,
                                  height: 4,
                                  color: ((i + j) % 2 == 0)
                                      ? Colors.amber.withValues(alpha: 0.7)
                                      : Colors.lightBlueAccent.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      // Window mullions (Corporate glass partitions)
                      Positioned.fill(
                        child: Row(
                          children: [
                            Expanded(child: Container()),
                            const VerticalDivider(color: Colors.white24, width: 2),
                            Expanded(child: Container()),
                            const VerticalDivider(color: Colors.white24, width: 2),
                            Expanded(child: Container()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Boardroom table surface
              Positioned(
                bottom: 80,
                left: 10,
                right: 10,
                height: 80,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.elliptical(320, 80)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF332014).withValues(alpha: 0.8),
                        const Color(0xFF1A1009),
                      ],
                    ),
                    border: Border.all(color: const Color(0xFF8B5A2B).withValues(alpha: 0.4)),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'debate_arena':
      case 'courtroom':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1C130D),
                Color(0xFF2E1C12),
                Color(0xFF120A06),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Scales of Justice Emblem on back oak wall
              Positioned(
                top: 70,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.balance_rounded,
                        size: 48,
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.4 + anim * 0.15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'HIGH COURT BENCH & JURY',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Elevated Judge Bench
              Positioned(
                bottom: 90,
                left: 30,
                right: 30,
                height: 70,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B2215), Color(0xFF25130A)],
                    ),
                    border: Border.all(color: const Color(0xFF8B5A2B), width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'thesis_hall':
      case 'university_hall':
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F1A2E),
                Color(0xFF152238),
                Color(0xFF080D18),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Academic Chalkboard / Projection Screen
              Positioned(
                top: 60,
                left: 30,
                right: 30,
                height: 140,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF163228),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF8B5A2B), width: 3),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THESIS DEFENSE JURY EVALUATION',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Problem Hypothesis & Empirical Data\n2. Methodology Defense under cross-examination\n3. Statistical Significance & Conclusions',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          height: 1.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

      case 'lounge':
      case 'bedroom':
      default:
        return Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, 0.1),
              radius: 1.2,
              colors: [
                Color(0xFF261E38),
                Color(0xFF140F22),
                Color(0xFF0B0814),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Acoustic Foam Hexagon Wall Pattern
              Positioned(
                top: 60,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    5,
                    (i) => Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Center(
                        child: Icon(Icons.waves_rounded, color: Colors.white12, size: 22),
                      ),
                    ),
                  ),
                ),
              ),
              // Warm studio lamp light
              Positioned(
                top: 40,
                right: 30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.amberAccent.withValues(alpha: 0.35 + anim * 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildLightingEffects(String envId, double anim) {
    if (envId == 'tedx_stage' || envId == 'auditorium') {
      return CustomPaint(
        painter: _SpotlightPainter(anim: anim),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCrowdSilhouettes(String envId, double anim) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Dark gradient floor wash
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black,
                  ],
                ),
              ),
            ),

            // Back row of crowd silhouettes (Distant listeners)
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              height: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(8, (i) {
                  final bob = math.sin((anim * math.pi * 2) + i) * 2.0;
                  return Transform.translate(
                    offset: Offset(0, bob),
                    child: _buildAudienceMember(size: 32, opacity: 0.35),
                  );
                }),
              ),
            ),

            // Front row of crowd silhouettes (Close, prominent audience heads & shoulders)
            Positioned(
              bottom: 0,
              left: 10,
              right: 10,
              height: 110,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(6, (i) {
                  final bob = math.cos((anim * math.pi * 2) + i * 1.5) * 3.5;
                  return Transform.translate(
                    offset: Offset(0, bob),
                    child: _buildAudienceMember(size: 46, opacity: 0.7),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAudienceMember({required double size, required double opacity}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Head
        Container(
          width: size * 0.55,
          height: size * 0.55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: opacity),
          ),
        ),
        const SizedBox(height: 2),
        // Shoulders
        Container(
          width: size,
          height: size * 0.5,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: opacity),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final double anim;
  _SpotlightPainter({required this.anim});

  @override
  void paint(Canvas canvas, Size size) {
    // Left Spotlight Beam
    final leftPath = Path()
      ..moveTo(size.width * 0.15, 0)
      ..lineTo(size.width * 0.25, 0)
      ..lineTo(size.width * 0.65, size.height * 0.85)
      ..lineTo(size.width * 0.35, size.height * 0.85)
      ..close();

    final leftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.22 + anim * 0.08),
          const Color(0xFFE50914).withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(leftPath, leftPaint);

    // Right Spotlight Beam
    final rightPath = Path()
      ..moveTo(size.width * 0.85, 0)
      ..lineTo(size.width * 0.75, 0)
      ..lineTo(size.width * 0.35, size.height * 0.85)
      ..lineTo(size.width * 0.65, size.height * 0.85)
      ..close();

    final rightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.22 + anim * 0.08),
          const Color(0xFFE50914).withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(rightPath, rightPaint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) => oldDelegate.anim != anim;
}
