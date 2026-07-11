// screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const SplashScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  int _dotIndex = 0;
  Timer? _dotTimer;
  Timer? _navigateTimer;
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();

    _dotTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        _dotIndex = (_dotIndex + 1) % 3;
      });
    });

    _navigateTimer = Timer(const Duration(milliseconds: 3200), () {
      widget.onNext();
    });

    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    _navigateTimer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B3A5C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ========== LOGO & TITLE (TENGAH) ==========
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo dengan pulse rings
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulse ring 1
                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 1400),
                          tween: Tween<double>(begin: 0.8, end: 1.2),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFF4FC3F7).withOpacity(0.25 * (1 - (value - 0.8) / 0.4)),
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                          onEnd: () {},
                        ),
                        // Pulse ring 2 (delay)
                        TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 1400),
                          tween: Tween<double>(begin: 0.8, end: 1.2),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFF4FC3F7).withOpacity(0.12 * (1 - (value - 0.8) / 0.4)),
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                          onEnd: () {},
                        ),
                        // Logo box
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E5A8A),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _spinController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _spinController.value * 2 * 3.14159,
                                  child: SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: CustomPaint(
                                      painter: OxygenRingPainter(
                                        progress: _spinController.value,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'OxyWatch',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI monitoring untuk si kecil',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // ========== DOT LOADER & VERSION ==========
              Column(
                children: [
                  // Dot loader
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final bool isActive = index == _dotIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF4FC3F7)
                              : const Color(0xFF4FC3F7).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'v1.0',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== CUSTOM PAINTER UNTUK OXYGEN RING ==========
class OxygenRingPainter extends CustomPainter {
  final double progress;

  OxygenRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 14.0;

    // Outer ring (background)
    final bgPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // Animated ring
    final ringPaint = Paint()
      ..color = const Color(0xFF4FC3F7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      ringPaint,
    );

    // Center dot
    final dotPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.9);

    canvas.drawCircle(center, 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant OxygenRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}