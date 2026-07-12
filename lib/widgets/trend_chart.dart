// widgets/trend_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/languages.dart';

class TrendChart extends StatelessWidget {
  const TrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final isProfileEmpty = auth.nama.isEmpty && auth.usia.isEmpty;

    // Data dummy untuk 10 log terakhir
    final List<Map<String, dynamic>> dailyData = [
      {'time': '00:00', 'spo2': 98.0, 'hr': 99.0, 'status': 'normal'},
      {'time': '03:00', 'spo2': 97.0, 'hr': 95.0, 'status': 'normal'},
      {'time': '06:00', 'spo2': 98.0, 'hr': 105.0, 'status': 'normal'},
      {'time': '09:00', 'spo2': 97.0, 'hr': 110.0, 'status': 'normal'},
      {'time': '10:00', 'spo2': 89.0, 'hr': 162.0, 'status': 'critical'},
      {'time': '12:00', 'spo2': 96.0, 'hr': 115.0, 'status': 'warning'},
      {'time': '15:00', 'spo2': 99.0, 'hr': 100.0, 'status': 'normal'},
      {'time': '18:00', 'spo2': 94.0, 'hr': 122.0, 'status': 'warning'},
      {'time': '21:00', 'spo2': 97.0, 'hr': 108.0, 'status': 'normal'},
      {'time': '23:00', 'spo2': 98.0, 'hr': 103.0, 'status': 'normal'},
    ];

    // Hitung statistik
    final spo2Values = dailyData.map((e) => (e['spo2'] as num).toDouble()).toList();
    final hrValues = dailyData.map((e) => (e['hr'] as num).toDouble()).toList();
    final avgSpo2 = spo2Values.reduce((a, b) => a + b) / spo2Values.length;
    final alertCount = dailyData.where((e) => e['status'] == 'warning' || e['status'] == 'critical').length;
    final avgHr = hrValues.reduce((a, b) => a + b) / hrValues.length;

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
          // Header dengan statistik
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10 ${lang.logPengukuran} ${lang.terakhir}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1B3A5C),
                ),
              ),
              if (!isProfileEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: alertCount > 0 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '⚠️ $alertCount ${lang.totalAlert}',
                    style: TextStyle(
                      fontSize: 10,
                      color: alertCount > 0 ? Colors.red.shade700 : Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // Stats mini - hanya tampil jika ada profil
          if (!isProfileEmpty)
            Row(
              children: [
                _buildMiniStat(lang.rataRataSpo2, '${avgSpo2.toStringAsFixed(1)}%', const Color(0xFF4FC3F7)),
                const SizedBox(width: 12),
                _buildMiniStat(lang.rataRataHR, '${avgHr.toStringAsFixed(0)} bpm', const Color(0xFF22C55E)),
              ],
            ),
          const SizedBox(height: 12),
          // Chart
          if (isProfileEmpty)
            _buildEmptyChart(lang)
          else
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.15),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= dailyData.length) return const Text('');
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              dailyData[index]['time'] as String,
                              style: const TextStyle(fontSize: 8, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 8, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  minX: 0,
                  maxX: dailyData.length - 1,
                  minY: 70,
                  maxY: 170,
                  lineBarsData: [
                    // SpO2 Line (Biru)
                    LineChartBarData(
                      spots: dailyData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['spo2'] as double);
                      }).toList(),
                      isCurved: true,
                      color: const Color(0xFF4FC3F7),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final dataPoint = dailyData[index];
                          Color dotColor;
                          switch (dataPoint['status']) {
                            case 'critical':
                              dotColor = Colors.red;
                              break;
                            case 'warning':
                              dotColor = Colors.orange;
                              break;
                            default:
                              dotColor = const Color(0xFF4FC3F7);
                          }
                          return FlDotCirclePainter(
                            radius: 4,
                            color: dotColor,
                            strokeWidth: 1.5,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // HR Line (Hijau)
                    LineChartBarData(
                      spots: dailyData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['hr'] as double);
                      }).toList(),
                      isCurved: true,
                      color: const Color(0xFF22C55E),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final dataPoint = dailyData[index];
                          Color dotColor;
                          switch (dataPoint['status']) {
                            case 'critical':
                              dotColor = Colors.red;
                              break;
                            case 'warning':
                              dotColor = Colors.orange;
                              break;
                            default:
                              dotColor = const Color(0xFF22C55E);
                          }
                          return FlDotCirclePainter(
                            radius: 4,
                            color: dotColor,
                            strokeWidth: 1.5,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Average Line (Merah Putus-putus)
                    LineChartBarData(
                      spots: [
                        FlSpot(0, avgSpo2),
                        FlSpot(dailyData.length - 1, avgSpo2),
                      ],
                      isCurved: false,
                      color: Colors.red,
                      barWidth: 1.5,
                      isStrokeCapRound: true,
                      dashArray: [6, 4],
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          // Legend - hanya tampil jika ada profil
          if (!isProfileEmpty)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildLegendItem(lang.spo2, const Color(0xFF4FC3F7)),
                _buildLegendItem('HR', const Color(0xFF22C55E)),
                _buildLegendItem('${lang.rataRata} SpO₂', Colors.red, isDashed: true),
                _buildLegendItem(lang.normal, Colors.green.shade700, isCircle: true),
                _buildLegendItem(lang.warning, Colors.orange, isCircle: true),
                _buildLegendItem(lang.kritis, Colors.red, isCircle: true),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF94A3B8),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color,
      {bool isDashed = false, bool isCircle = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCircle)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          )
        else if (isDashed)
          Container(
            width: 16,
            height: 2,
            color: Colors.transparent,
            child: CustomPaint(
              painter: DashedLineLegendPainter(color: color),
            ),
          )
        else
          Container(
            width: 16,
            height: 2,
            color: color,
          ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChart(AppLocalizations lang) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 40,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              lang.belumAdaData,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lang.isiProfilDulu,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ========== DASHED LINE LEGEND PAINTER ==========
class DashedLineLegendPainter extends CustomPainter {
  final Color color;

  DashedLineLegendPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 5;
    const dashSpace = 3;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DashedLineLegendPainter oldDelegate) => false;
}