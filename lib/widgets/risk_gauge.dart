// lib/widgets/risk_gauge.dart
//
// Custom arc gauge widget. Input: score (0-100). Output: gauge melengkung
// dengan warna otomatis sesuai level risiko.

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/risk_helper.dart';

class RiskGauge extends StatelessWidget {
  final int score; // 0-100
  final String level; // "NORMAL" | "WASPADA" | "BAHAYA"
  final double size;

  const RiskGauge({
    super.key,
    required this.score,
    required this.level,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    final color = riskColor(level);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(score: score, color: color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$score",
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                riskLabel(level),
                style: TextStyle(
                  fontSize: size * 0.09,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int score;
  final Color color;

  _GaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    final trackPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    const startAngle = math.pi * 0.75;
    const sweepFull = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepFull,
      false,
      trackPaint,
    );

    final sweepValue = sweepFull * (score.clamp(0, 100) / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepValue,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}