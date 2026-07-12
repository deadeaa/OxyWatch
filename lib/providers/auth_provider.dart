import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'language_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isProfileCompleted = false;
  String? _error;
  UserModel? _currentUser;
  String _language = 'id';

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
  String get language => _language;

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

        await _loadProfileData();

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

  // ==========================
  // LOAD PROFILE DATA
  // ==========================

  Future<void> _loadProfileData() async {
    if (_currentUser == null) return;

    try {
      final data = await _authService.getUserDataMap(_currentUser!.uid);
      if (data != null) {
        _patientId = data['patientId'] ?? '';
        _nama = data['nama'] ?? '';
        _usia = data['usia'] ?? '';
        _bb = data['bb'] ?? '';
        _tb = data['tb'] ?? '';
        _goldar = data['goldar'] ?? '';
        _riwayat = data['riwayat'] is List ? List<String>.from(data['riwayat']) : [];
        _alertSpO2 = data['alertSpO2'] ?? true;
        _alertHR = data['alertHR'] ?? true;
        _watchConnected = data['watchConnected'] ?? false;
        _watchBattery = data['watchBattery'] ?? '0%';
        _deviceName = data['deviceName'] ?? '';
        _isProfileCompleted = data['profileCompleted'] ?? false;
        _language = data['language'] ?? 'id';
      }
    } catch (e) {
      debugPrint("Error loading profile data: $e");
    }
  }

  // ==========================
  // UPDATE LANGUAGE
  // ==========================

  Future<void> updateUserLanguage(String langCode) async {
    _language = langCode;
    if (_currentUser != null) {
      await _authService.updateUserData(_currentUser!.uid, {
        'language': langCode,
      });
    }
    notifyListeners();
  }

  // ==========================
  // LOAD PROFILE DATA (PUBLIC)
  // ==========================

  Future<void> loadUserData() async {
    await _loadProfileData();
    notifyListeners();
  }

  // ==========================
  // LOGOUT
  // ==========================

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
    _language = 'id';
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

    _patientId = patientId.isNotEmpty
        ? patientId
        : 'PED-${DateTime.now().millisecondsSinceEpoch.toString().substring(6, 10)}';

    _isProfileCompleted = true;

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
        'language': _language,
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
    if (data.containsKey('riwayat')) _riwayat = data['riwayat'] is List ? List<String>.from(data['riwayat']) : [];
    if (data.containsKey('alertSpO2')) _alertSpO2 = data['alertSpO2'];
    if (data.containsKey('alertHR')) _alertHR = data['alertHR'];
    if (data.containsKey('deviceName')) _deviceName = data['deviceName'] ?? '';
    if (data.containsKey('watchConnected')) _watchConnected = data['watchConnected'];
    if (data.containsKey('watchBattery')) _watchBattery = data['watchBattery'] ?? '0%';
    if (data.containsKey('profileCompleted')) _isProfileCompleted = data['profileCompleted'];
    if (data.containsKey('language')) {
      _language = data['language'];
    }
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
  // DELETE PROFILE
  // ==========================

  Future<void> deleteProfile() async {
    if (_currentUser == null) return;

    try {
      await _authService.deleteUserData(_currentUser!.uid);
      await _authService.deleteAccount();

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
      _language = 'id';
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting profile: $e");
      rethrow;
    }
  }
}