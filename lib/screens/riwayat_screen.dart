// screens/riwayat_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../utils/languages.dart';
import '../providers/auth_provider.dart';
import '../models/riwayat_model.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String _selectedFilter = 'Hari ini';
  final List<String> _filters = ['Hari ini', 'Minggu ini', 'Bulan ini'];
  List<RiwayatModel> _data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _data = RiwayatModel.getDataForFilter(_selectedFilter);
    });
  }

  Map<String, dynamic> _calculateStats() {
    if (_data.isEmpty) {
      return {'avgSpo2': 0.0, 'avgHr': 0.0, 'totalAlert': 0};
    }

    final spo2Values = _data.map((d) => d.spo2).toList();
    final hrValues = _data.map((d) => d.hr).toList();
    final alertCount = _data.where((d) => d.status == 'warning' || d.status == 'critical').length;

    return {
      'avgSpo2': spo2Values.reduce((a, b) => a + b) / spo2Values.length,
      'avgHr': hrValues.reduce((a, b) => a + b) / hrValues.length,
      'totalAlert': alertCount,
    };
  }

  int _getLabelInterval() {
    switch (_selectedFilter) {
      case 'Hari ini':
        return 2;
      case 'Minggu ini':
        return 1;
      case 'Bulan ini':
        return 1;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isProfileEmpty = auth.nama.isEmpty && auth.usia.isEmpty;
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(lang.riwayatMonitoring),
        backgroundColor: const Color(0xFF1B3A5C),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              if (!isProfileEmpty) {
                _showExportDialog(context, lang);
              }
            },
          ),
        ],
      ),
      body: isProfileEmpty
          ? _buildEmptyState(lang)
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filter
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                String displayName = filter;
                if (filter == 'Hari ini') displayName = lang.hariIni;
                else if (filter == 'Minggu ini') displayName = lang.mingguIni;
                else if (filter == 'Bulan ini') displayName = lang.bulanIni;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                      _loadData();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1B3A5C) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Stats
            _buildStats(lang),
            const SizedBox(height: 16),
            // Chart
            _buildChart(lang),
            const SizedBox(height: 16),
            // Legend
            _buildLegend(lang),
            const SizedBox(height: 16),
            // Log Table
            _buildLogTable(lang),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            lang.belumAdaRiwayat,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            lang.isiProfilDulu,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ========== STATS ==========
  Widget _buildStats(AppLocalizations lang) {
    final stats = _calculateStats();
    return Row(
      children: [
        _buildStatCard(
          lang.rataRataSpo2,
          '${stats['avgSpo2'].toStringAsFixed(1)}%',
          const Color(0xFF4FC3F7),
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          lang.rataRataHR,
          '${stats['avgHr'].toStringAsFixed(0)} bpm',
          const Color(0xFF22C55E),
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          lang.totalAlert,
          '${stats['totalAlert']}',
          const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0E1E3C).withOpacity(0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  // ========== CHART ==========
  Widget _buildChart(AppLocalizations lang) {
    if (_data.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0E1E3C).withOpacity(0.07)),
        ),
        child: const Center(
          child: Text('Belum ada data', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final stats = _calculateStats();
    final avgSpo2 = stats['avgSpo2'] as double;
    final labelInterval = _getLabelInterval();

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
          Text(
            _selectedFilter == 'Hari ini'
                ? '${lang.spo2} & HR — 24 ${lang.jam}'
                : _selectedFilter == 'Minggu ini'
                ? '${lang.spo2} & HR — 7 ${lang.hari}'
                : '${lang.spo2} & HR — 4 ${lang.minggu}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B3A5C)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
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
                      reservedSize: 30,
                      interval: labelInterval.toDouble(),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= _data.length) return const Text('');
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _data[index].getTranslatedXLabel(lang),
                            style: const TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
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
                maxX: _data.length - 1,
                minY: 70,
                maxY: 170,
                lineBarsData: [
                  // SpO2 Line (Biru)
                  LineChartBarData(
                    spots: _data.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.spo2);
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF4FC3F7),
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final dataPoint = _data[index];
                        Color dotColor;
                        switch (dataPoint.status) {
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
                          radius: 5,
                          color: dotColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                  // HR Line (Hijau)
                  LineChartBarData(
                    spots: _data.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.hr);
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF22C55E),
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        final dataPoint = _data[index];
                        Color dotColor;
                        switch (dataPoint.status) {
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
                          radius: 5,
                          color: dotColor,
                          strokeWidth: 2,
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
                      FlSpot(_data.length - 1, avgSpo2),
                    ],
                    isCurved: false,
                    color: Colors.red,
                    barWidth: 1.5,
                    isStrokeCapRound: true,
                    dashArray: [8, 6],
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== LEGEND ==========
  Widget _buildLegend(AppLocalizations lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0E1E3C).withOpacity(0.07)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 6,
        children: [
          _buildLegendItem(lang.spo2, const Color(0xFF4FC3F7)),
          _buildLegendItem('HR', const Color(0xFF22C55E)),
          _buildLegendItem('${lang.rataRata} SpO₂', Colors.red, isDashed: true),
          _buildLegendItem(lang.normal, Colors.green.shade700, isCircle: true),
          _buildLegendItem(lang.warning, Colors.orange, isCircle: true),
          _buildLegendItem(lang.kritis, Colors.red, isCircle: true),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color,
      {bool isDashed = false, bool isCircle = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isCircle)
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          )
        else if (isDashed)
          Container(
            width: 20,
            height: 2,
            color: Colors.transparent,
            child: CustomPaint(
              painter: DashedLinePainter(color: color),
            ),
          )
        else
          Container(
            width: 20,
            height: 3,
            color: color,
          ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ========== LOG TABLE ==========
  Widget _buildLogTable(AppLocalizations lang) {
    if (_data.isEmpty) {
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
        child: Center(
          child: Text(
            'Tidak ada data',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

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
          Text(
            '${lang.logPengukuran} - ${_selectedFilter == 'Hari ini' ? lang.hariIni : _selectedFilter == 'Minggu ini' ? lang.mingguIni : lang.bulanIni}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B3A5C),
            ),
          ),
          const SizedBox(height: 12),
          // HEADER TABLE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // Time
                Expanded(
                  flex: 2,
                  child: Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // SpO2
                Expanded(
                  flex: 1,
                  child: Text(
                    lang.spo2,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // HR
                Expanded(
                  flex: 2,
                  child: Text(
                    'HR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Status
                Expanded(
                  flex: 2,
                  child: Text(
                    lang.status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // LOG ROWS
          ..._data.map((log) => _buildLogRow(log, lang)),
        ],
      ),
    );
  }

  Widget _buildLogRow(RiwayatModel log, AppLocalizations lang) {
    Color bgColor, borderColor, chipBg, chipTextColor;
    String statusText;

    switch (log.status) {
      case 'warning':
        bgColor = const Color(0xFFFFFBEB).withOpacity(0.6);
        borderColor = const Color(0xFFF59E0B).withOpacity(0.3);
        statusText = lang.warning;
        chipBg = const Color(0xFFFDE68A).withOpacity(0.7);
        chipTextColor = const Color(0xFF92400E);
        break;
      case 'critical':
        bgColor = const Color(0xFFFFF5F5).withOpacity(0.6);
        borderColor = const Color(0xFFEF4444).withOpacity(0.3);
        statusText = lang.kritis;
        chipBg = const Color(0xFFFEE2E2).withOpacity(0.7);
        chipTextColor = const Color(0xFFEF4444);
        break;
      default:
        bgColor = Colors.white.withOpacity(0.6);
        borderColor = Colors.transparent;
        statusText = lang.normal;
        chipBg = const Color(0xFFD1FAE5).withOpacity(0.7);
        chipTextColor = const Color(0xFF22C55E);
    }

    final displayLabel = log.getTranslatedLabel(lang);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor == Colors.transparent
              ? Colors.grey.withOpacity(0.05)
              : borderColor,
        ),
      ),
      child: Row(
        children: [
          // Time
          Expanded(
            flex: 2,
            child: Text(
              displayLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // SpO2
          Expanded(
            flex: 1,
            child: Text(
              '${log.spo2.toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: log.status == 'critical' ? Colors.red : const Color(0xFF1B3A5C),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // HR
          Expanded(
            flex: 2,
            child: Text(
              '${log.hr.toInt()} bpm',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: log.status == 'critical' ? Colors.red : const Color(0xFF1B3A5C),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Status - RATA TENGAH
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: chipTextColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, AppLocalizations lang) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3A5C).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.file_download, color: Color(0xFF1B3A5C), size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                lang.exportPDFTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3A5C)),
              ),
              const SizedBox(height: 8),
              Text(
                lang.exportPDFSubtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lang.exportPDFInfo,
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        lang.batal,
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(lang.exportPDFSuccess),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B3A5C),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        lang.exportPDF,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
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

// ========== DASHED LINE PAINTER ==========
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6;
    const dashSpace = 4;
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
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) => false;
}