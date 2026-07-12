import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_scoring_service.dart';
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
}