// providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isProfileCompleted = false;
  String? _error;
  UserModel? _currentUser;

  // Patient data
  String _patientId = '';
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
  String _deviceName = '';

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isProfileCompleted => _isProfileCompleted;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;
  String get patientId => _patientId;
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
  String get deviceName => _deviceName;

  // ==========================
  // AUTH METHODS
  // ==========================

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );

      if (result.success) {
        _currentUser = result.user;
        _isLoggedIn = true;
        // Doctor langsung selesai, parent perlu onboarding
        _isProfileCompleted = role == UserRole.doctor;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result.success) {
        _currentUser = result.user;
        _isLoggedIn = true;
        _isProfileCompleted = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _isProfileCompleted = false;
    _currentUser = null;
    _patientId = '';
    _nama = '';
    _usia = '';
    _bb = '';
    _tb = '';
    _goldar = '';
    _riwayat = [];
    _watchConnected = false;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await _authService.resetPassword(email);
  }

  // ==========================
  // PROFILE METHODS
  // ==========================

  void setProfile({
    required String nama,
    required String usia,
    required String bb,
    required String tb,
    required String goldar,
    required List<String> riwayat,
    required bool alertSpO2,
    required bool alertHR,
    String patientId = '',
  }) {
    _nama = nama;
    _usia = usia;
    _bb = bb;
    _tb = tb;
    _goldar = goldar;
    _riwayat = riwayat;
    _alertSpO2 = alertSpO2;
    _alertHR = alertHR;

    // Kalau patientId dikirim dari pemanggil, pakai itu.
    // Kalau tidak, auto-generate seperti semula.
    _patientId = patientId.isNotEmpty
        ? patientId
        : 'PED-${DateTime.now().millisecondsSinceEpoch.toString().substring(6, 10)}';

    _isProfileCompleted = true;

    // 🔥 SAVE KE FIRESTORE
    _saveToFirestore();

    notifyListeners();
  }

  Future<void> _saveToFirestore() async {
    if (_currentUser == null) return;

    try {
      await _authService.updateUserData(_currentUser!.uid, {
        'patientId': _patientId,
        'nama': _nama,
        'usia': _usia,
        'bb': _bb,
        'tb': _tb,
        'goldar': _goldar,
        'riwayat': _riwayat,
        'alertSpO2': _alertSpO2,
        'alertHR': _alertHR,
        'profileCompleted': true,
      });
    } catch (e) {
      debugPrint("Error saving profile to Firestore: $e");
    }
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
    if (data.containsKey('deviceName')) _deviceName = data['deviceName'] ?? '';
    notifyListeners();
  }

  void connectWatch({String deviceName = 'Galaxy Watch 4'}) {
    _watchConnected = true;
    _deviceName = deviceName;
    _watchBattery = '78%';
    notifyListeners();
  }

  void disconnectWatch() {
    _watchConnected = false;
    _deviceName = '';
    _watchBattery = '0%';
    notifyListeners();
  }

  // ==========================
  // LOAD FROM FIRESTORE
  // ==========================

  Future<void> loadUserData() async {
    if (_currentUser == null) return;

    try {
      final userData = await _authService.getUserData(_currentUser!.uid);
      if (userData != null) {
        _patientId = userData.userCode;
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }
}