// screens/riwayat_screen.dart
import 'package:flutter/material.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String _selectedFilter = 'Hari ini';
  final List<Map<String, dynamic>> _logs = [];
  final List<Map<String, dynamic>> _weeklyLogs = [];
  final List<Map<String, dynamic>> _monthlyLogs = [];

  final List<String> _filters = ['Hari ini', 'Minggu ini', 'Bulan ini'];

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _loadWeeklyLogs();
    _loadMonthlyLogs();
  }

  void _loadLogs() {
    _logs.addAll([
      {'time': '23:42', 'spo2': '98', 'hr': '103', 'status': 'Normal'},
      {'time': '21:15', 'spo2': '97', 'hr': '108', 'status': 'Normal'},
      {'time': '18:30', 'spo2': '94', 'hr': '122', 'status': 'Warning'},
      {'time': '15:10', 'spo2': '99', 'hr': '100', 'status': 'Normal'},
      {'time': '12:45', 'spo2': '96', 'hr': '115', 'status': 'Normal'},
      {'time': '10:00', 'spo2': '89', 'hr': '162', 'status': 'Kritis'},
      {'time': '08:20', 'spo2': '97', 'hr': '106', 'status': 'Normal'},
      {'time': '06:00', 'spo2': '98', 'hr': '99', 'status': 'Normal'},
    ]);
  }

  void _loadWeeklyLogs() {
    _weeklyLogs.addAll([
      {'day': 'Sen', 'spo2': '97.5', 'hr': '110', 'status': 'Normal'},
      {'day': 'Sel', 'spo2': '96.2', 'hr': '115', 'status': 'Normal'},
      {'day': 'Rab', 'spo2': '94.8', 'hr': '122', 'status': 'Warning'},
      {'day': 'Kam', 'spo2': '97.0', 'hr': '108', 'status': 'Normal'},
      {'day': 'Jum', 'spo2': '95.5', 'hr': '118', 'status': 'Normal'},
      {'day': 'Sab', 'spo2': '93.0', 'hr': '130', 'status': 'Warning'},
      {'day': 'Min', 'spo2': '96.5', 'hr': '112', 'status': 'Normal'},
    ]);
  }

  void _loadMonthlyLogs() {
    _monthlyLogs.addAll([
      {'week': 'Minggu 1', 'spo2': '96.8', 'hr': '112', 'status': 'Normal'},
      {'week': 'Minggu 2', 'spo2': '95.2', 'hr': '120', 'status': 'Warning'},
      {'week': 'Minggu 3', 'spo2': '97.1', 'hr': '108', 'status': 'Normal'},
      {'week': 'Minggu 4', 'spo2': '94.5', 'hr': '125', 'status': 'Warning'},
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Riwayat Monitoring',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1B3A5C),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              _exportPDF(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== FILTER CHIP ==========
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1B3A5C) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      filter,
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

            // ========== STAT CARD ==========
            if (_selectedFilter == 'Hari ini')
              _buildDailyStats()
            else if (_selectedFilter == 'Minggu ini')
              _buildWeeklyStats()
            else
              _buildMonthlyStats(),

            const SizedBox(height: 16),

            // ========== GRAFIK ==========
            if (_selectedFilter == 'Hari ini')
              _buildDailyChart()
            else if (_selectedFilter == 'Minggu ini')
              _buildWeeklyChart()
            else
              _buildMonthlyChart(),

            const SizedBox(height: 16),

            // ========== LOG ==========
            if (_selectedFilter == 'Hari ini')
              _buildDailyLog()
            else if (_selectedFilter == 'Minggu ini')
              _buildWeeklyLog()
            else
              _buildMonthlyLog(),
          ],
        ),
      ),
    );
  }

  // ========== STATS ==========
  Widget _buildDailyStats() {
    return Row(
      children: [
        _buildStatCard('Rata-rata SpO₂', '97.2%', const Color(0xFF4FC3F7)),
        const SizedBox(width: 8),
        _buildStatCard('Rata-rata HR', '108 bpm', const Color(0xFF22C55E)),
        const SizedBox(width: 8),
        _buildStatCard('Total Alert', '2', const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildWeeklyStats() {
    return Row(
      children: [
        _buildStatCard('Rata-rata SpO₂', '95.8%', const Color(0xFF4FC3F7)),
        const SizedBox(width: 8),
        _buildStatCard('Rata-rata HR', '116 bpm', const Color(0xFF22C55E)),
        const SizedBox(width: 8),
        _buildStatCard('Total Alert', '5', const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildMonthlyStats() {
    return Row(
      children: [
        _buildStatCard('Rata-rata SpO₂', '95.9%', const Color(0xFF4FC3F7)),
        const SizedBox(width: 8),
        _buildStatCard('Rata-rata HR', '116 bpm', const Color(0xFF22C55E)),
        const SizedBox(width: 8),
        _buildStatCard('Total Alert', '12', const Color(0xFFEF4444)),
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== CHART ==========
  Widget _buildDailyChart() {
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
            'SpO₂ & HR — 24 jam',
            style: TextStyle(
              color: Color(0xFF1B3A5C),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: ChartPainter(
                spo2Data: [98, 97, 94, 99, 96, 89, 97, 98],
                hrData: [103, 108, 122, 100, 115, 162, 106, 99],
                labels: ['00:00', '06:00', '12:00', '18:00'],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('00:00', style: TextStyle(color: Colors.grey, fontSize: 9)),
              Text('06:00', style: TextStyle(color: Colors.grey, fontSize: 9)),
              Text('12:00', style: TextStyle(color: Colors.grey, fontSize: 9)),
              Text('18:00', style: TextStyle(color: Colors.grey, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildLegend('SpO₂', const Color(0xFF4FC3F7)),
              const SizedBox(width: 16),
              _buildLegend('HR', const Color(0xFFFF6B6B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
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
            'SpO₂ & HR — 7 Hari',
            style: TextStyle(
              color: Color(0xFF1B3A5C),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: ChartPainter(
                spo2Data: [97.5, 96.2, 94.8, 97.0, 95.5, 93.0, 96.5],
                hrData: [110, 115, 122, 108, 118, 130, 112],
                labels: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Sen', style: TextStyle(color: Colors.grey, fontSize: 9)),
              Text('Sel', style: TextStyle(color: Colors.grey, fontSize: 9)),
              Text('Rab', style: TextStyle(color: Colors.grey, fontSize: 9)),
              Text('Kam', style: TextStyle(color: Colors.grey, fontSize: 9)),
              Text('Jum', style: TextStyle(color: Colors.grey, fontSize: 9)),
              Text('Sab', style: TextStyle(color: Colors.grey, fontSize: 9)),
              Text('Min', style: TextStyle(color: Colors.grey, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildLegend('SpO₂', const Color(0xFF4FC3F7)),
              const SizedBox(width: 16),
              _buildLegend('HR', const Color(0xFFFF6B6B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
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
            'SpO₂ & HR — 4 Minggu',
            style: TextStyle(
              color: Color(0xFF1B3A5C),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: ChartPainter(
                spo2Data: [96.8, 95.2, 97.1, 94.5],
                hrData: [112, 120, 108, 125],
                labels: ['M1', 'M2', 'M3', 'M4'],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Minggu 1', style: TextStyle(color: Colors.grey, fontSize: 9)),
              Text('Minggu 2', style: TextStyle(color: Colors.grey, fontSize: 9)),
              Text('Minggu 3', style: TextStyle(color: Colors.grey, fontSize: 9)),
              Text('Minggu 4', style: TextStyle(color: Colors.grey, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildLegend('SpO₂', const Color(0xFF4FC3F7)),
              const SizedBox(width: 16),
              _buildLegend('HR', const Color(0xFFFF6B6B)),
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
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ========== LOG ==========
  Widget _buildDailyLog() {
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
            'Log Pengukuran - Hari ini',
            style: TextStyle(
              color: Color(0xFF1B3A5C),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _buildLogTable(_logs),
        ],
      ),
    );
  }

  Widget _buildWeeklyLog() {
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
            'Ringkasan Harian - Minggu ini',
            style: TextStyle(
              color: Color(0xFF1B3A5C),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _buildWeeklyTable(),
        ],
      ),
    );
  }

  Widget _buildMonthlyLog() {
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
            'Ringkasan Mingguan - Bulan ini',
            style: TextStyle(
              color: Color(0xFF1B3A5C),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _buildMonthlyTable(),
        ],
      ),
    );
  }

  // ========== TABLE LOG ==========
  Widget _buildLogTable(List<Map<String, dynamic>> data) {
    return Column(
      children: [
        Row(
          children: [
            _buildTableHeader('Time', flex: 1),
            _buildTableHeader('SpO₂', flex: 1),
            _buildTableHeader('HR', flex: 1),
            _buildTableHeader('Status', flex: 1.5),
          ],
        ),
        const SizedBox(height: 8),
        ...data.map((log) => _buildLogRow(log)),
      ],
    );
  }

  Widget _buildWeeklyTable() {
    return Column(
      children: [
        Row(
          children: [
            _buildTableHeader('Hari', flex: 1),
            _buildTableHeader('SpO₂', flex: 1),
            _buildTableHeader('HR', flex: 1),
            _buildTableHeader('Status', flex: 1.5),
          ],
        ),
        const SizedBox(height: 8),
        ..._weeklyLogs.map((log) => _buildWeeklyRow(log)),
      ],
    );
  }

  Widget _buildMonthlyTable() {
    return Column(
      children: [
        Row(
          children: [
            _buildTableHeader('Minggu', flex: 1),
            _buildTableHeader('SpO₂', flex: 1),
            _buildTableHeader('HR', flex: 1),
            _buildTableHeader('Status', flex: 1.5),
          ],
        ),
        const SizedBox(height: 8),
        ..._monthlyLogs.map((log) => _buildMonthlyRow(log)),
      ],
    );
  }

  Widget _buildTableHeader(String text, {double flex = 1}) {
    return Expanded(
      flex: flex.toInt(),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildLogRow(Map<String, dynamic> log) {
    Color statusColor;
    Color bgColor;

    switch (log['status']) {
      case 'Kritis':
        statusColor = Colors.red;
        bgColor = Colors.red.withOpacity(0.05);
        break;
      case 'Warning':
        statusColor = Colors.orange;
        bgColor = Colors.orange.withOpacity(0.05);
        break;
      default:
        statusColor = Colors.green;
        bgColor = Colors.transparent;
    }

    final isKritis = log['status'] == 'Kritis';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isKritis ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              log['time'],
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${log['spo2']}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isKritis ? FontWeight.bold : FontWeight.w500,
                color: isKritis ? Colors.red : const Color(0xFF1B3A5C),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${log['hr']} bpm',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isKritis ? FontWeight.bold : FontWeight.w500,
                color: isKritis ? Colors.red : const Color(0xFF1B3A5C),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                log['status'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyRow(Map<String, dynamic> log) {
    Color statusColor;
    switch (log['status']) {
      case 'Kritis':
        statusColor = Colors.red;
        break;
      case 'Warning':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              log['day'],
              style: const TextStyle(
                color: Color(0xFF1B3A5C),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${log['spo2']}%',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1B3A5C),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${log['hr']} bpm',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1B3A5C),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                log['status'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyRow(Map<String, dynamic> log) {
    Color statusColor;
    switch (log['status']) {
      case 'Kritis':
        statusColor = Colors.red;
        break;
      case 'Warning':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              log['week'],
              style: const TextStyle(
                color: Color(0xFF1B3A5C),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${log['spo2']}%',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1B3A5C),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${log['hr']} bpm',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1B3A5C),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                log['status'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportPDF(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export PDF sedang dalam pengembangan'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

// ========== CHART PAINTER ==========
class ChartPainter extends CustomPainter {
  final List<double> spo2Data;
  final List<double> hrData;
  final List<String> labels;

  ChartPainter({
    required this.spo2Data,
    required this.hrData,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintSpo2 = Paint()
      ..color = const Color(0xFF4FC3F7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintHr = Paint()
      ..color = const Color(0xFFFF6B6B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = (i / 3) * height;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Find min/max for scaling
    final allValues = [...spo2Data, ...hrData];
    final minVal = allValues.reduce((a, b) => a < b ? a : b) - 5;
    final maxVal = allValues.reduce((a, b) => a > b ? a : b) + 5;
    final range = maxVal - minVal;

    // SpO2 Line
    final pathSpo2 = Path();
    for (int i = 0; i < spo2Data.length; i++) {
      final x = (i / (spo2Data.length - 1)) * width;
      final y = height - ((spo2Data[i] - minVal) / range) * height;
      if (i == 0) {
        pathSpo2.moveTo(x, y);
      } else {
        pathSpo2.lineTo(x, y);
      }
    }
    canvas.drawPath(pathSpo2, paintSpo2);

    // HR Line
    final pathHr = Path();
    for (int i = 0; i < hrData.length; i++) {
      final x = (i / (hrData.length - 1)) * width;
      final y = height - ((hrData[i] - minVal) / range) * height;
      if (i == 0) {
        pathHr.moveTo(x, y);
      } else {
        pathHr.lineTo(x, y);
      }
    }
    canvas.drawPath(pathHr, paintHr);

    // Y-axis labels
    final labelsY = [maxVal.toStringAsFixed(0), ((maxVal + minVal) / 2).toStringAsFixed(0), minVal.toStringAsFixed(0)];
    final textStyle = TextStyle(
      fontSize: 7,
      color: Colors.grey.shade500,
    );
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < labelsY.length; i++) {
      final y = height - (i / (labelsY.length - 1)) * height;
      textPainter.text = TextSpan(text: labelsY[i], style: textStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 3));
    }
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return oldDelegate.spo2Data != spo2Data ||
        oldDelegate.hrData != hrData ||
        oldDelegate.labels != labels;
  }
}