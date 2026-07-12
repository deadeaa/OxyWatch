import 'package:flutter/material.dart';
import 'dart:async';

class OxyWatchLogo extends StatefulWidget {
  final double size;
  final bool showAnimation;
  final bool showPulse;

  const OxyWatchLogo({
    super.key,
    this.size = 64,
    this.showAnimation = true,
    this.showPulse = true,
  });

  @override
  State<OxyWatchLogo> createState() => _OxyWatchLogoState();
}

class _OxyWatchLogoState extends State<OxyWatchLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final innerSize = size * 0.8;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse rings
          if (widget.showPulse) ...[
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 1400),
              tween: Tween<double>(begin: 0.8, end: 1.2),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size * 0.28),
                      border: Border.all(
                        color: const Color(0xFF4FC3F7).withOpacity(
                          0.25 * (1 - (value - 0.8) / 0.4),
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 1400),
              tween: Tween<double>(begin: 0.8, end: 1.2),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size * 0.28),
                      border: Border.all(
                        color: const Color(0xFF4FC3F7).withOpacity(
                          0.12 * (1 - (value - 0.8) / 0.4),
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
          // Inner box
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              color: const Color(0xFF2E5A8A),
              borderRadius: BorderRadius.circular(innerSize * 0.28),
            ),
            child: Center(
              child: widget.showAnimation
                  ? AnimatedBuilder(
                animation: _spinController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _spinController.value * 2 * 3.14159,
                    child: SizedBox(
                      width: innerSize * 0.6,
                      height: innerSize * 0.6,
                      child: CustomPaint(
                        painter: OxygenRingPainter(
                          progress: _spinController.value,
                          ringColor: const Color(0xFF4FC3F7),
                        ),
                      ),
                    ),
                  );
                },
              )
                  : const Icon(
                Icons.monitor_heart_outlined,
                color: Color(0xFF4FC3F7),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OxygenRingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;

  OxygenRingPainter({
    required this.progress,
    this.ringColor = const Color(0xFF4FC3F7),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = ringColor.withOpacity(0.2)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    // Animated ring
    final ringPaint = Paint()
      ..color = ringColor
      ..strokeWidth = 2.5
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
      ..color = ringColor.withOpacity(0.9);

    canvas.drawCircle(center, radius * 0.35, dotPaint);
  }

  @override
  bool shouldRepaint(covariant OxygenRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.ringColor != ringColor;
  }
}