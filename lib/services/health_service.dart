// services/health_service.dart
import 'package:health/health.dart';

/// Service pembungkus Health Connect untuk membaca data
/// Heart Rate & SpO2 terbaru dari Galaxy Fit3 (via Samsung Health).
class HealthService {
  final Health _health = Health();

  static const List<HealthDataType> _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
  ];

  bool _isConfigured = false;

  Future<void> _ensureConfigured() async {
    if (_isConfigured) return;
    await _health.configure();
    _isConfigured = true;
  }

  /// Minta izin akses Health Connect. Return true kalau granted.
  Future<bool> requestPermissions() async {
    await _ensureConfigured();
    return await _health.requestAuthorization(_types);
  }

  /// Ambil heart rate & SpO2 terbaru (dari 1 jam terakhir).
  ///
  /// Return null kalau proses gagal total (misal: Health Connect
  /// tidak ter-install, atau exception lain).
  /// Kalau berhasil tapi datanya kosong, tetap return record dengan
  /// heartRate/spo2 bernilai null (bukan exception), supaya pemanggil
  /// bisa membedakan "gagal akses" vs "belum ada data baru".
  Future<({int? heartRate, int? spo2})?> getLatestVitals() async {
    try {
      await _ensureConfigured();

      final hasPermission = await _health.hasPermissions(_types) ?? false;
      if (!hasPermission) {
        final granted = await _health.requestAuthorization(_types);
        if (!granted) return null;
      }

      final now = DateTime.now();
      // Pakai window 24 jam (bukan 1 jam) supaya pengukuran yang
      // dilakukan beberapa jam lalu tetap kebaca sebagai data terbaru.
      final oneDayAgo = now.subtract(const Duration(hours: 24));

      final data = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: oneDayAgo,
        endTime: now,
      );

      if (data.isEmpty) {
        return (heartRate: null, spo2: null);
      }

      // Urutkan dari yang paling baru
      data.sort((a, b) => b.dateTo.compareTo(a.dateTo));

      int? heartRate;
      int? spo2;

      for (final point in data) {
        if (heartRate == null && point.type == HealthDataType.HEART_RATE) {
          final value = point.value;
          if (value is NumericHealthValue) {
            heartRate = value.numericValue.round();
          }
        }
        if (spo2 == null && point.type == HealthDataType.BLOOD_OXYGEN) {
          final value = point.value;
          if (value is NumericHealthValue) {
            // Health Connect menyimpan SpO2 sebagai fraksi (0.0-1.0),
            // sedangkan OxyWatch pakai skala persen (0-100).
            final raw = value.numericValue;
            spo2 = (raw <= 1.0 ? raw * 100 : raw).round();
          }
        }
        if (heartRate != null && spo2 != null) break;
      }

      return (heartRate: heartRate, spo2: spo2);
    } catch (e) {
      return null;
    }
  }
}