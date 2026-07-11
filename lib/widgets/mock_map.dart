// widgets/mock_map.dart
import 'package:flutter/material.dart';

class MockMap extends StatelessWidget {
  const MockMap({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MockMapPainter(),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    final bgPaint = Paint()..color = const Color(0xFFE8EAED);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Block fills (buildings)
    final blockColor = const Color(0xFFD4D8DC);
    final blockPaint = Paint()..color = blockColor;
    final blockColor2 = const Color(0xFFD9DDE0);
    final blockPaint2 = Paint()..color = blockColor2;
    final parkColor = const Color(0xFFC8DFC8);
    final parkPaint = Paint()..color = parkColor;

    // Buildings
    canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.205, h * 0.143), blockPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.256, 10, w * 0.256, h * 0.107), blockPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.564, 0, w * 0.179, h * 0.131), blockPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.795, 5, w * 0.205, h * 0.119), blockPaint);

    canvas.drawRect(Rect.fromLTWH(0, h * 0.190, w * 0.141, h * 0.190), blockPaint2);
    canvas.drawRect(Rect.fromLTWH(w * 0.192, h * 0.190, w * 0.231, h * 0.167), blockPaint2);
    canvas.drawRect(Rect.fromLTWH(w * 0.474, h * 0.179, w * 0.218, h * 0.190), blockPaint2);
    canvas.drawRect(Rect.fromLTWH(w * 0.744, h * 0.190, w * 0.256, h * 0.143), blockPaint2);

    // Green park
    canvas.drawRect(Rect.fromLTWH(w * 0.359, h * 0.690, w * 0.141, h * 0.107), parkPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.077, h * 0.464, w * 0.090, h * 0.071), parkPaint);

    // Main roads (horizontal)
    final roadPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, h * 0.148, w, h * 0.038), roadPaint);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.381, w, h * 0.038), roadPaint);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.607, w, h * 0.038), roadPaint);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.857, w, h * 0.038), roadPaint);

    // Main roads (vertical)
    canvas.drawRect(Rect.fromLTWH(w * 0.159, 0, w * 0.036, h), roadPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.423, 0, w * 0.036, h), roadPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.687, 0, w * 0.036, h), roadPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.936, 0, w * 0.036, h), roadPaint);

    // Side roads
    final sideRoadPaint = Paint()..color = const Color(0xFFF0F1F2);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.310, w, h * 0.019), sideRoadPaint);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.524, w, h * 0.019), sideRoadPaint);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.762, w, h * 0.019), sideRoadPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.295, 0, w * 0.021, h), sideRoadPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.551, 0, w * 0.021, h), sideRoadPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.808, 0, w * 0.021, h), sideRoadPaint);

    // 🔥 ROUTE LINE - FIX: Pakai Path langsung
    final routePath = Path();
    routePath.moveTo(w * 0.5, h * 0.810);
    routePath.lineTo(w * 0.5, h * 0.607);
    routePath.lineTo(w * 0.687, h * 0.607);
    routePath.lineTo(w * 0.687, h * 0.381);
    routePath.lineTo(w * 0.441, h * 0.381);
    routePath.lineTo(w * 0.441, h * 0.238);

    // Route glow
    final glowPaint = Paint()
      ..color = const Color(0xFF4EA8DE).withOpacity(0.18)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, glowPaint);

    // Route line
    final routePaint = Paint()
      ..color = const Color(0xFF4EA8DE)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, routePaint);

    // User location pin (bottom)
    final userPinPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.5, h * 0.821), 14, userPinPaint);
    final bluePaint = Paint()..color = const Color(0xFF4EA8DE);
    canvas.drawCircle(Offset(w * 0.5, h * 0.821), 10, bluePaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.821), 5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.5, h * 0.821), 28, Paint()..color = const Color(0xFF4EA8DE).withOpacity(0.15));

    // 🔥 Hospital pin - FIX: Pakai drawOval
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.15);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.441, h * 0.262), width: 12, height: 6),
      shadowPaint,
    );

    // Hospital building
    final hospitalPaint = Paint()..color = const Color(0xFFEF4444);
    final hospitalPath = Path()
      ..moveTo(w * 0.441, h * 0.205)
      ..quadraticBezierTo(w * 0.397, h * 0.238, w * 0.397, h * 0.262)
      ..quadraticBezierTo(w * 0.397, h * 0.286, w * 0.418, h * 0.305)
      ..quadraticBezierTo(w * 0.441, h * 0.315, w * 0.464, h * 0.305)
      ..quadraticBezierTo(w * 0.485, h * 0.286, w * 0.485, h * 0.262)
      ..quadraticBezierTo(w * 0.485, h * 0.238, w * 0.441, h * 0.205)
      ..close();
    canvas.drawPath(hospitalPath, hospitalPaint);

    // Plus sign on hospital
    final plusPaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.441, h * 0.260), width: 4, height: 12),
      plusPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(w * 0.441, h * 0.260), width: 12, height: 4),
      plusPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}