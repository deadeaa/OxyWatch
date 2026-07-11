// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitoring_provider.dart';
import '../providers/notifikasi_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/patient_card.dart';
import '../widgets/risk_score_card.dart';
import '../screens/emergency_monitor_screen.dart';
import '../screens/notifikasi_screen.dart';
import '../screens/pengaturan_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isProfileEmpty = auth.nama.isEmpty && auth.usia.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF1B3A5C),
        elevation: 0,
        actions: [
          Consumer<NotifikasiProvider>(
            builder: (context, notifProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotifikasiScreen(),
                        ),
                      );
                    },
                  ),
                  if (notifProvider.belumDibaca > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '${notifProvider.belumDibaca}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PengaturanScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 PATIENT CARD - PAKAI DATA DARI AUTH
              PatientCard(),
              const SizedBox(height: 16),

              // Vital Signs Row - PAKAI DATA DARI AUTH
              Row(
                children: [
                  Expanded(
                    child: _buildVitalCard(
                      title: 'SpO₂',
                      value: isProfileEmpty ? '-' : '98',
                      unit: isProfileEmpty ? '' : '%',
                      status: isProfileEmpty ? 'Belum ada' : 'Normal',
                      statusColor: isProfileEmpty ? Colors.grey : Colors.green,
                      icon: Icons.bloodtype,
                      isEmpty: isProfileEmpty,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVitalCard(
                      title: 'Detak jantung',
                      value: isProfileEmpty ? '-' : '105',
                      unit: isProfileEmpty ? '' : 'bpm',
                      status: isProfileEmpty ? 'Belum ada' : 'Normal',
                      statusColor: isProfileEmpty ? Colors.grey : Colors.green,
                      icon: Icons.favorite,
                      isEmpty: isProfileEmpty,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Risk Score Card
              isProfileEmpty
                  ? _buildEmptyCard('Belum ada data risk score')
                  : const RiskScoreCard(),
              const SizedBox(height: 16),

              // 🔥 TREN 7 HARI - FIX PADDING
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0E1E3C).withOpacity(0.07)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tren 7 Hari',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B3A5C),
                          ),
                        ),
                        Row(
                          children: [
                            _buildLegendItem('SpO₂', const Color(0xFF4FC3F7)),
                            const SizedBox(width: 12),
                            _buildLegendItem('HR', const Color(0xFF22C55E)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isProfileEmpty)
                      _buildEmptyChart()
                    else
                    // 🔥 TAMBAHKAN PADDING KIRI UNTUK LABEL
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: SizedBox(
                          height: 100,
                          child: CustomPaint(
                            painter: TrendChartPainter(
                              spo2Data: [98, 97, 95, 96, 94, 93, 95],
                              hrData: [105, 108, 112, 115, 120, 125, 118],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Sen', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        Text('Sel', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        Text('Rab', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        Text('Kam', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        Text('Jum', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        Text('Sab', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                        Text('Min', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Emergency
              GestureDetector(
                onTap: isProfileEmpty
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyMonitorScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isProfileEmpty ? Colors.grey.shade200 : const Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isProfileEmpty ? Colors.grey.shade300 : const Color(0xFFEF4444),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: isProfileEmpty ? Colors.grey.shade400 : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isProfileEmpty ? 'Isi profil terlebih dahulu' : '🚨 Emergency',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isProfileEmpty ? Colors.grey.shade500 : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalCard({
    required String title,
    required String value,
    required String unit,
    required String status,
    required Color statusColor,
    required IconData icon,
    required bool isEmpty,
  }) {
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
          Row(
            children: [
              Icon(icon, color: isEmpty ? Colors.grey.shade400 : const Color(0xFF1B3A5C), size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isEmpty ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isEmpty ? Colors.grey.shade400 : const Color(0xFF1B3A5C),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: isEmpty ? Colors.grey.shade400 : Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'Belum ada data',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ========== TREND CHART PAINTER - FIX ==========
class TrendChartPainter extends CustomPainter {
  final List<double> spo2Data;
  final List<double> hrData;

  TrendChartPainter({
    required this.spo2Data,
    required this.hrData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // 🔥 GRID LINES
    final gridPaint = Paint()
      ..color = const Color(0xFF0E1E3C).withOpacity(0.05)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 4; i++) {
      final y = (i / 3) * height;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // 🔥 SPO2 LINE
    final paintSpo2 = Paint()
      ..color = const Color(0xFF4FC3F7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pathSpo2 = Path();
    for (int i = 0; i < spo2Data.length; i++) {
      final x = (i / (spo2Data.length - 1)) * width;
      final y = height - ((spo2Data[i] - 90) / 10) * height;
      if (i == 0) {
        pathSpo2.moveTo(x, y);
      } else {
        pathSpo2.lineTo(x, y);
      }
    }
    canvas.drawPath(pathSpo2, paintSpo2);

    // 🔥 HR LINE
    final paintHr = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pathHr = Path();
    for (int i = 0; i < hrData.length; i++) {
      final x = (i / (hrData.length - 1)) * width;
      final y = height - ((hrData[i] - 100) / 30) * height;
      if (i == 0) {
        pathHr.moveTo(x, y);
      } else {
        pathHr.lineTo(x, y);
      }
    }
    canvas.drawPath(pathHr, paintHr);

    // 🔥 Y-AXIS LABELS - di dalam kotak
    const labels = ['0', '60', '120'];
    final textStyle = TextStyle(
      fontSize: 8,
      color: const Color(0xFF94A3B8),
      fontWeight: FontWeight.w400,
    );
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < labels.length; i++) {
      final y = height - (i / (labels.length + 0.4)) * height;
      textPainter.text = TextSpan(text: labels[i], style: textStyle);
      textPainter.layout();
      // 🔥 POSISI LABEL - di DALAM grafik (tidak keluar)
      textPainter.paint(canvas, Offset(-17, y - 24));
    }
  }

  @override
  bool shouldRepaint(covariant TrendChartPainter oldDelegate) {
    return oldDelegate.spo2Data != spo2Data || oldDelegate.hrData != hrData;
  }
}