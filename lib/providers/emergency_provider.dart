// providers/emergency_provider.dart
import 'package:flutter/material.dart';

class EmergencyProvider extends ChangeNotifier {
  bool _isEmergency = false;

  bool get isEmergency => _isEmergency;

  void triggerEmergency() {
    _isEmergency = true;
    notifyListeners();
  }

  void deactivateEmergency() {
    _isEmergency = false;
    notifyListeners();
  }
}