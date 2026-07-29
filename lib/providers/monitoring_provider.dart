import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_scoring_service.dart';
import '../services/health_service.dart';
import '../models/risk_score_model.dart';
import 'emergency_provider.dart';
import 'auth_provider.dart';
import 'language_provider.dart';

class MonitoringProvider extends ChangeNotifier {
  int _spo2 = 98;
  int _heartRate = 105;
  bool _isEmergency = false;
  RiskScoreModel? _currentRiskScore;

  int get spo2 => _spo2;
  int get heartRate => _heartRate;
  bool get isEmergency => _isEmergency;
  RiskScoreModel? get currentRiskScore => _currentRiskScore;

  void updateVitalSigns(int spo2, int heartRate, BuildContext context) {
    _spo2 = spo2;
    _heartRate = heartRate;
    _checkEmergency(context);
    _calculateRiskScore(context);
    notifyListeners();
  }

  void _checkEmergency(BuildContext context) {
    final emergencyProvider = Provider.of<EmergencyProvider>(context, listen: false);

    if (_spo2 <= 90 || _heartRate > 150) {
      if (!_isEmergency) {
        _isEmergency = true;
        emergencyProvider.triggerEmergency();
      }
    } else {
      if (_isEmergency) {
        _isEmergency = false;
        emergencyProvider.deactivateEmergency();
      }
    }
  }

  void _calculateRiskScore(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    final age = int.tryParse(authProvider.usia) ?? 3;
    final weight = double.tryParse(authProvider.bb) ?? 14.0;
    final height = double.tryParse(authProvider.tb) ?? 95.0;
    final isEnglish = languageProvider.currentLanguage == 'en';

    final result = AIScoringService.predict(
      age: age,
      weight: weight,
      height: height,
      spo2: _spo2.toDouble(),
      hr: _heartRate.toDouble(),
      isEnglish: isEnglish,
    );

    _currentRiskScore = RiskScoreModel.fromMap(result);
  }

  void resetEmergency() {
    _isEmergency = false;
    notifyListeners();
  }

  void simulateData(BuildContext context) {
    updateVitalSigns(98, 105, context);
  }

  void simulateEmergency(BuildContext context) {
    updateVitalSigns(89, 162, context);
  }

  // ============================================================
  // Health Connect sync (Galaxy Fit3 -> Samsung Health -> Health
  // Connect -> OxyWatch)
  // ============================================================

  final HealthService _healthService = HealthService();
  Timer? _healthSyncTimer;
  bool _isSyncingHealth = false;

  bool get isSyncingHealth => _isSyncingHealth;

  /// Mulai sinkronisasi berkala dari Health Connect (tiap 5 menit).
  /// Langsung sync sekali di awal, tidak nunggu 5 menit pertama.
  Future<void> startHealthSync(BuildContext context) async {
    _healthSyncTimer?.cancel();

    await _syncFromHealthConnect(context);

    _healthSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      await _syncFromHealthConnect(context);
    });
  }

  void stopHealthSync() {
    _healthSyncTimer?.cancel();
    _healthSyncTimer = null;
  }

  Future<void> _syncFromHealthConnect(BuildContext context) async {
    _isSyncingHealth = true;
    notifyListeners();

    final vitals = await _healthService.getLatestVitals();

    _isSyncingHealth = false;

    if (vitals == null) {
      // Gagal akses Health Connect (izin belum ada / Health Connect
      // tidak ter-install). Data lama tetap dipertahankan, tidak
      // ditimpa dengan 0 supaya tidak menampilkan angka salah.
      notifyListeners();
      return;
    }

    final newSpo2 = vitals.spo2 ?? _spo2;
    final newHeartRate = vitals.heartRate ?? _heartRate;

    if (!context.mounted) return;

    // updateVitalSigns sudah otomatis notifyListeners() di dalamnya
    updateVitalSigns(newSpo2, newHeartRate, context);
  }

  @override
  void dispose() {
    _healthSyncTimer?.cancel();
    super.dispose();
  }
}