// widgets/trend_chart.dart
import 'package:flutter/material.dart';

class TrendChart extends StatelessWidget {
  const TrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tren 7 Hari',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1B3A5C),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildLegend('SpO₂', const Color(0xFF1B3A5C)),
              const SizedBox(width: 16),
              _buildLegend('HR', const Color(0xFFFF6B6B)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: TrendChartPainter(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Sen', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('Sel', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('Rab', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('Kam', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('Jum', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('Sab', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('Min', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}

class TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintSpo2 = Paint()
      ..color = const Color(0xFF1B3A5C)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintHr = Paint()
      ..color = const Color(0xFFFF6B6B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;

    final spo2Data = [98, 97, 95, 96, 94, 93, 95];
    final hrData = [105, 108, 112, 115, 120, 125, 118];

    final pathSpo2 = Path();
    for (int i = 0; i < spo2Data.length; i++) {
      final x = (i / (spo2Data.length - 1)) * width;
      final y = height - (spo2Data[i] - 90) / 10 * height;
      if (i == 0) {
        pathSpo2.moveTo(x, y);
      } else {
        pathSpo2.lineTo(x, y);
      }
    }
    canvas.drawPath(pathSpo2, paintSpo2);

    final pathHr = Path();
    for (int i = 0; i < hrData.length; i++) {
      final x = (i / (hrData.length - 1)) * width;
      final y = height - (hrData[i] - 100) / 30 * height;
      if (i == 0) {
        pathHr.moveTo(x, y);
      } else {
        pathHr.lineTo(x, y);
      }
    }
    canvas.drawPath(pathHr, paintHr);

    const labels = ['120', '60', '0'];
    final textStyle = TextStyle(fontSize: 8, color: Colors.grey.shade500);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < labels.length; i++) {
      final y = height - (i / (labels.length - 1)) * height;
      textPainter.text = TextSpan(text: labels[i], style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(-16, y - 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}