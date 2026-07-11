// providers/auth_provider.dart
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isProfileCompleted = false;

  String _nama = '';
  String _usia = '';
  String _bb = '';
  String _tb = '';
  String _goldar = '';
  List<String> _riwayat = [];
  bool _alertSpO2 = true;
  bool _alertHR = true;
  bool _watchConnected = false;
  String _watchBattery = '0%';
  String _patientId = '';

  // 🔥 TAMBAHKAN DEVICE NAME
  String _deviceName = '';

  bool get isLoggedIn => _isLoggedIn;
  bool get isProfileCompleted => _isProfileCompleted;
  String get nama => _nama;
  String get usia => _usia;
  String get bb => _bb;
  String get tb => _tb;
  String get goldar => _goldar;
  List<String> get riwayat => _riwayat;
  bool get alertSpO2 => _alertSpO2;
  bool get alertHR => _alertHR;
  bool get watchConnected => _watchConnected;
  String get watchBattery => _watchBattery;
  String get patientId => _patientId;
  String get deviceName => _deviceName;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _isProfileCompleted = false;
    _nama = '';
    _usia = '';
    _bb = '';
    _tb = '';
    _goldar = '';
    _riwayat = [];
    _patientId = '';
    _watchConnected = false;
    _deviceName = '';
    notifyListeners();
  }

  void setProfile({
    required String nama,
    required String usia,
    required String bb,
    required String tb,
    required String goldar,
    required List<String> riwayat,
    required bool alertSpO2,
    required bool alertHR,
    required String patientId,
  }) {
    _nama = nama;
    _usia = usia;
    _bb = bb;
    _tb = tb;
    _goldar = goldar;
    _riwayat = riwayat;
    _alertSpO2 = alertSpO2;
    _alertHR = alertHR;
    _patientId = patientId.isNotEmpty ? patientId : 'PED-0000';
    notifyListeners();
  }

  void setProfileCompleted(bool value) {
    _isProfileCompleted = value;
    notifyListeners();
  }

  void updateProfile(Map<String, dynamic> data) {
    if (data.containsKey('nama')) _nama = data['nama'] ?? '';
    if (data.containsKey('usia')) _usia = data['usia'] ?? '';
    if (data.containsKey('bb')) _bb = data['bb'] ?? '';
    if (data.containsKey('tb')) _tb = data['tb'] ?? '';
    if (data.containsKey('goldar')) _goldar = data['goldar'] ?? '';
    if (data.containsKey('riwayat')) _riwayat = data['riwayat'] is List ? data['riwayat'] : [];
    if (data.containsKey('alertSpO2')) _alertSpO2 = data['alertSpO2'];
    if (data.containsKey('alertHR')) _alertHR = data['alertHR'];
    if (data.containsKey('patientId')) _patientId = data['patientId'] ?? '';
    if (data.containsKey('deviceName')) _deviceName = data['deviceName'] ?? '';
    notifyListeners();
  }

  void connectWatch() {
    _watchConnected = true;
    _watchBattery = '78%';
    notifyListeners();
  }

  void disconnectWatch() {
    _watchConnected = false;
    _watchBattery = '0%';
    _deviceName = '';
    notifyListeners();
  }
}