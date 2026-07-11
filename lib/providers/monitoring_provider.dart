// providers/monitoring_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'emergency_provider.dart';

class MonitoringProvider extends ChangeNotifier {
  MonitoringProvider();

  int _spo2 = 98;
  int _heartRate = 105;
  bool _isEmergency = false;

  int get spo2 => _spo2;
  int get heartRate => _heartRate;
  bool get isEmergency => _isEmergency;

  void updateVitalSigns(int spo2, int heartRate, BuildContext context) {
    _spo2 = spo2;
    _heartRate = heartRate;
    _checkEmergency(context);
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