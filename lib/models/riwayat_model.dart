// models/riwayat_model.dart
import '../utils/languages.dart';

class RiwayatModel {
  final String label;      // Label untuk display di log
  final String xLabel;     // Label khusus untuk sumbu X chart (lebih pendek)
  final double spo2;
  final double hr;
  final String status;     // 'normal', 'warning', 'critical'
  final DateTime timestamp;

  RiwayatModel({
    required this.label,
    required this.xLabel,
    required this.spo2,
    required this.hr,
    required this.status,
    required this.timestamp,
  });

  // Untuk translate label di log
  String getTranslatedLabel(AppLocalizations lang) {
    // Jika bahasa Indonesia, return label asli
    if (lang.locale.languageCode == 'id') {
      return label;
    }

    // Translate hari (ID → EN) - FULL
    final dayMap = {
      'Senin': 'Monday',
      'Selasa': 'Tuesday',
      'Rabu': 'Wednesday',
      'Kamis': 'Thursday',
      'Jumat': 'Friday',
      'Sabtu': 'Saturday',
      'Minggu': 'Sunday',
    };

    // Translate minggu (ID → EN)
    final weekMap = {
      'Minggu 1': 'Week 1',
      'Minggu 2': 'Week 2',
      'Minggu 3': 'Week 3',
      'Minggu 4': 'Week 4',
    };

    if (dayMap.containsKey(label)) {
      return dayMap[label]!;
    }
    if (weekMap.containsKey(label)) {
      return weekMap[label]!;
    }
    return label;
  }

  // Untuk translate xLabel (sumbu X chart)
  String getTranslatedXLabel(AppLocalizations lang) {
    // Jika bahasa Indonesia, return xLabel asli
    if (lang.locale.languageCode == 'id') {
      return xLabel;
    }

    // Translate singkatan hari (ID → EN)
    final shortDayMap = {
      'Sen': 'Mon',
      'Sel': 'Tue',
      'Rab': 'Wed',
      'Kam': 'Thu',
      'Jum': 'Fri',
      'Sab': 'Sat',
      'Min': 'Sun',
    };

    // Translate minggu (ID → EN) - tetap "Week 1", "Week 2", dst
    final weekMap = {
      'M1': 'Week 1',
      'M2': 'Week 2',
      'M3': 'Week 3',
      'M4': 'Week 4',
    };

    if (shortDayMap.containsKey(xLabel)) {
      return shortDayMap[xLabel]!;
    }
    if (weekMap.containsKey(xLabel)) {
      return weekMap[xLabel]!;
    }
    return xLabel;
  }

  // Untuk get status dalam bahasa
  String getStatusText(AppLocalizations lang) {
    switch (status) {
      case 'normal':
        return lang.normal;
      case 'warning':
        return lang.warning;
      case 'critical':
        return lang.kritis;
      default:
        return status;
    }
  }

  // ========== DATA DUMMY ==========

  // Data 24 Jam (per 2 jam)
  static List<RiwayatModel> generateDailyData() {
    return [
      RiwayatModel(
          label: '00:00',
          xLabel: '00:00',
          spo2: 98,
          hr: 103,
          status: 'normal',
          timestamp: DateTime(2025, 6, 17, 0, 0)
      ),
      RiwayatModel(
          label: '02:00',
          xLabel: '02:00',
          spo2: 97,
          hr: 105,
          status: 'normal',
          timestamp: DateTime(2025, 6, 17, 2, 0)
      ),
      RiwayatModel(
          label: '04:00',
          xLabel: '04:00',
          spo2: 96,
          hr: 108,
          status: 'normal',
          timestamp: DateTime(2025, 6, 17, 4, 0)
      ),
      RiwayatModel(
          label: '06:00',
          xLabel: '06:00',
          spo2: 98,
          hr: 99,
          status: 'normal',
          timestamp: DateTime(2025, 6, 17, 6, 0)
      ),
      RiwayatModel(
          label: '08:00',
          xLabel: '08:00',
          spo2: 97,
          hr: 106,
          status: 'normal',
          timestamp: DateTime(2025, 6, 17, 8, 0)
      ),
      RiwayatModel(
          label: '10:00',
          xLabel: '10:00',
          spo2: 89,
          hr: 162,
          status: 'critical',
          timestamp: DateTime(2025, 6, 17, 10, 0)
      ),
      RiwayatModel(
          label: '12:00',
          xLabel: '12:00',
          spo2: 96,
          hr: 115,
          status: 'warning',
          timestamp: DateTime(2025, 6, 17, 12, 0)
      ),
      RiwayatModel(
          label: '14:00',
          xLabel: '14:00',
          spo2: 99,
          hr: 100,
          status: 'normal',
          timestamp: DateTime(2025, 6, 17, 14, 0)
      ),
      RiwayatModel(
          label: '16:00',
          xLabel: '16:00',
          spo2: 97,
          hr: 110,
          status: 'normal',
          timestamp: DateTime(2025, 6, 17, 16, 0)
      ),
      RiwayatModel(
          label: '18:00',
          xLabel: '18:00',
          spo2: 94,
          hr: 122,
          status: 'warning',
          timestamp: DateTime(2025, 6, 17, 18, 0)
      ),
      RiwayatModel(
          label: '20:00',
          xLabel: '20:00',
          spo2: 97,
          hr: 108,
          status: 'normal',
          timestamp: DateTime(2025, 6, 17, 20, 0)
      ),
      RiwayatModel(
          label: '22:00',
          xLabel: '22:00',
          spo2: 98,
          hr: 103,
          status: 'normal',
          timestamp: DateTime(2025, 6, 17, 22, 0)
      ),
    ];
  }

  // Data 1 Minggu
  static List<RiwayatModel> generateWeeklyData() {
    return [
      RiwayatModel(
          label: 'Senin',
          xLabel: 'Sen',
          spo2: 97.5,
          hr: 110,
          status: 'normal',
          timestamp: DateTime(2025, 6, 10)
      ),
      RiwayatModel(
          label: 'Selasa',
          xLabel: 'Sel',
          spo2: 96.2,
          hr: 115,
          status: 'normal',
          timestamp: DateTime(2025, 6, 11)
      ),
      RiwayatModel(
          label: 'Rabu',
          xLabel: 'Rab',
          spo2: 89.0,
          hr: 160,
          status: 'critical',
          timestamp: DateTime(2025, 6, 12)
      ),
      RiwayatModel(
          label: 'Kamis',
          xLabel: 'Kam',
          spo2: 97.0,
          hr: 108,
          status: 'normal',
          timestamp: DateTime(2025, 6, 13)
      ),
      RiwayatModel(
          label: 'Jumat',
          xLabel: 'Jum',
          spo2: 95.5,
          hr: 118,
          status: 'warning',
          timestamp: DateTime(2025, 6, 14)
      ),
      RiwayatModel(
          label: 'Sabtu',
          xLabel: 'Sab',
          spo2: 93.0,
          hr: 130,
          status: 'warning',
          timestamp: DateTime(2025, 6, 15)
      ),
      RiwayatModel(
          label: 'Minggu',
          xLabel: 'Min',
          spo2: 96.5,
          hr: 112,
          status: 'normal',
          timestamp: DateTime(2025, 6, 16)
      ),
    ];
  }

  // Data 1 Bulan (per minggu)
  static List<RiwayatModel> generateMonthlyData() {
    return [
      RiwayatModel(
          label: 'Minggu 1',
          xLabel: 'M1',
          spo2: 96.8,
          hr: 112,
          status: 'normal',
          timestamp: DateTime(2025, 5, 25)
      ),
      RiwayatModel(
          label: 'Minggu 2',
          xLabel: 'M2',
          spo2: 95.2,
          hr: 120,
          status: 'warning',
          timestamp: DateTime(2025, 6, 1)
      ),
      RiwayatModel(
          label: 'Minggu 3',
          xLabel: 'M3',
          spo2: 97.1,
          hr: 108,
          status: 'normal',
          timestamp: DateTime(2025, 6, 8)
      ),
      RiwayatModel(
          label: 'Minggu 4',
          xLabel: 'M4',
          spo2: 88.0,
          hr: 165,
          status: 'critical',
          timestamp: DateTime(2025, 6, 15)
      ),
    ];
  }

  static List<RiwayatModel> getDataForFilter(String filter) {
    switch (filter) {
      case 'Hari ini':
        return generateDailyData();
      case 'Minggu ini':
        return generateWeeklyData();
      case 'Bulan ini':
        return generateMonthlyData();
      default:
        return generateDailyData();
    }
  }
}