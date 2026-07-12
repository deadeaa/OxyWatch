// screens/profil_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../utils/languages.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _namaController;
  late TextEditingController _usiaController;
  late TextEditingController _bbController;
  late TextEditingController _tbController;
  late TextEditingController _goldarController;
  List<String> _riwayatKondisi = [];
  final TextEditingController _kondisiController = TextEditingController();

  bool _alertSpO2 = true;
  bool _alertHR = true;
  bool _watchConnected = false;
  String _selectedGoldar = 'A+';
  String _connectedDeviceName = '';

  // Firebase
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _goldarOptions = [
    'A+', 'A-', 'B+', 'B-',
    'O+', 'O-', 'AB+', 'AB-'
  ];

  final List<Map<String, String>> _bluetoothDevices = [
    {'name': 'Galaxy Watch 4', 'address': 'XX:XX:XX:XX:XX:01'},
    {'name': 'Xiaomi Mi Band 7', 'address': 'XX:XX:XX:XX:XX:02'},
    {'name': 'Apple Watch Series 8', 'address': 'XX:XX:XX:XX:XX:03'},
    {'name': 'Huawei Band 7', 'address': 'XX:XX:XX:XX:XX:04'},
    {'name': 'Samsung Fit 3', 'address': 'XX:XX:XX:XX:XX:05'},
    {'name': 'Garmin Vivosmart 5', 'address': 'XX:XX:XX:XX:XX:06'},
  ];

  final List<Map<String, dynamic>> _bubbleData = [
    {'label': 'Asma ringan', 'color': Color(0xFFD97706), 'bg': Color(0xFFFFFBEB)},
    {'label': 'Lahir prematur', 'color': Color(0xFF0EA5E9), 'bg': Color(0xFFEFF8FF)},
    {'label': 'Alergi debu', 'color': Color(0xFF64748B), 'bg': Color(0xFFF8FAFC)},
    {'label': 'Riwayat 1', 'color': Color(0xFF8B5CF6), 'bg': Color(0xFFF5F3FF)},
    {'label': 'Riwayat 2', 'color': Color(0xFFEC4899), 'bg': Color(0xFFFDF2F8)},
    {'label': 'Riwayat 3', 'color': Color(0xFF14B8A6), 'bg': Color(0xFFF0FDFA)},
  ];

  @override
  void initState() {
    super.initState();
    _loadDataFromAuth();
  }

  void _loadDataFromAuth() {
    final auth = context.read<AuthProvider>();
    _namaController = TextEditingController(text: auth.nama);
    _usiaController = TextEditingController(text: auth.usia);
    _bbController = TextEditingController(text: auth.bb);
    _tbController = TextEditingController(text: auth.tb);
    _goldarController = TextEditingController(text: auth.goldar);
    _riwayatKondisi = List.from(auth.riwayat);
    _alertSpO2 = auth.alertSpO2;
    _alertHR = auth.alertHR;
    _watchConnected = auth.watchConnected;
    _selectedGoldar = auth.goldar.isNotEmpty ? auth.goldar : 'A+';
    _connectedDeviceName = auth.deviceName.isNotEmpty ? auth.deviceName : '';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usiaController.dispose();
    _bbController.dispose();
    _tbController.dispose();
    _goldarController.dispose();
    _kondisiController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  bool _isValidName(String name) {
    final trimmed = name.trim();
    return trimmed.length >= 2 && trimmed.split(' ').every((word) => word.isNotEmpty);
  }

  bool _isNumeric(String value) {
    return double.tryParse(value) != null && double.parse(value) > 0;
  }

  void _addKondisi() {
    if (_kondisiController.text.isNotEmpty) {
      setState(() {
        _riwayatKondisi.add(_kondisiController.text);
        _kondisiController.clear();
      });
    }
  }

  void _removeKondisi(int index) {
    setState(() {
      _riwayatKondisi.removeAt(index);
    });
  }

  void _copyPatientId(String patientId) {
    final lang = AppLocalizations.of(context)!;
    if (patientId.isNotEmpty && patientId != 'PED-0000') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.copy, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '✅ ${lang.patientIdCopied}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ========== SAVE TO FIREBASE ==========
  Future<void> _saveToFirebase(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore.collection('users').doc(user.uid).set(
        {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to save to Firebase: $e');
    }
  }

  void _saveEdit() async {
    final lang = AppLocalizations.of(context)!;

    if (!_isValidName(_namaController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.namaMinimal2),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_isNumeric(_usiaController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.usiaHarusAngka),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_isNumeric(_bbController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.bbHarusAngka),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_isNumeric(_tbController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.tbHarusAngka),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();

      final profileData = {
        'nama': _namaController.text.trim(),
        'usia': _usiaController.text.trim(),
        'bb': _bbController.text.trim(),
        'tb': _tbController.text.trim(),
        'goldar': _selectedGoldar,
        'riwayat': _riwayatKondisi,
        'alertSpO2': _alertSpO2,
        'alertHR': _alertHR,
      };

      // Update Firebase
      await _saveToFirebase(profileData);

      // Update AuthProvider
      auth.updateProfile(profileData);

      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lang.profilBerhasil,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ========== SMARTWATCH CONNECT POPUP ==========
  void _showSmartwatchConnectDialog(String deviceName) async {
    final lang = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bluetooth,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              lang.connectSmartwatch,
              style: const TextStyle(
                color: Color(0xFF1B3A5C),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${lang.connectTo} $deviceName?',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      deviceName,
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              lang.batal,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              try {
                final auth = context.read<AuthProvider>();
                auth.connectWatch();
                auth.updateProfile({'deviceName': deviceName});

                await _saveToFirebase({
                  'deviceName': deviceName,
                  'watchConnected': true,
                });

                setState(() {
                  _watchConnected = true;
                  _connectedDeviceName = deviceName;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '✅ $deviceName ${lang.connected}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ON',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Gagal menghubungkan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              lang.connect,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  // ========== SMARTWATCH DISCONNECT POPUP ==========
  void _showSmartwatchDisconnectDialog() {
    final lang = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bluetooth_disabled,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              lang.putuskan,
              style: const TextStyle(
                color: Color(0xFF1B3A5C),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              lang.disconnectConfirm,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lang.disconnectWarning,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              lang.batal,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              try {
                final auth = context.read<AuthProvider>();
                auth.disconnectWatch();
                auth.updateProfile({'deviceName': ''});

                await _saveToFirebase({
                  'deviceName': '',
                  'watchConnected': false,
                });

                setState(() {
                  _watchConnected = false;
                  _connectedDeviceName = '';
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            lang.smartwatchDiputuskan,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Gagal memutuskan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              lang.putuskan,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  // ========== ALERT TOGGLE POPUP ==========
  void _showAlertToggleDialog(String title, bool currentValue, Function(bool) onChanged) {
    final lang = AppLocalizations.of(context)!;
    final newValue = !currentValue;
    final status = newValue ? 'ON' : 'OFF';
    final icon = newValue ? Icons.notifications_active : Icons.notifications_off;
    final color = newValue ? Colors.green : Colors.grey;

    // 🔥 FIX: Buat message manual
    final String message;
    if (newValue) {
      message = lang.locale.languageCode == 'id'
          ? 'Apakah Anda ingin mengaktifkan alert $title?'
          : 'Do you want to enable alert $title?';
    } else {
      message = lang.locale.languageCode == 'id'
          ? 'Apakah Anda ingin menonaktifkan alert $title?'
          : 'Do you want to disable alert $title?';
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Alert $title',
              style: const TextStyle(
                color: Color(0xFF1B3A5C),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message, // 🔥 PAKAI MESSAGE YANG SUDAH DIBUAT
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(
                    newValue ? Icons.check_circle : Icons.cancel,
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${lang.statusLabel}: $status',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              lang.batal,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              onChanged(newValue);
              setState(() {
                if (title == 'SpO₂') {
                  _alertSpO2 = newValue;
                } else {
                  _alertHR = newValue;
                }
              });

              // Save to Firebase
              try {
                await _saveToFirebase({
                  'alertSpO2': _alertSpO2,
                  'alertHR': _alertHR,
                });
              } catch (e) {
                // Ignore, already saved in provider
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        newValue ? Icons.notifications_active : Icons.notifications_off,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '✅ Alert $title ${newValue ? lang.activated : lang.deactivated}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          newValue ? 'ON' : 'OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: newValue ? Colors.green : Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              newValue ? lang.activate : lang.deactivate,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showBluetoothPicker() {
    final lang = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      lang.selectBluetooth,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B3A5C),
                      ),
                    ),
                  ),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  ListTile(
                    leading: const Icon(Icons.search, color: Color(0xFF4FC3F7)),
                    title: Text(
                      lang.findNewDevice,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B3A5C),
                      ),
                    ),
                    subtitle: Text(
                      lang.scanNearby,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.pop(context);
                      _showScanningDialog();
                    },
                  ),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  ..._bluetoothDevices.map((device) => ListTile(
                    leading: const Icon(Icons.bluetooth, color: Color(0xFF4FC3F7)),
                    title: Text(
                      device['name']!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B3A5C),
                      ),
                    ),
                    subtitle: Text(
                      device['address']!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.pop(context);
                      _showSmartwatchConnectDialog(device['name']!);
                    },
                  )).toList(),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showScanningDialog() {
    final lang = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF4FC3F7)),
            const SizedBox(height: 16),
            Text(
              lang.searching,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B3A5C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lang.ensureBluetooth,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showBluetoothPicker();
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3A5C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(lang.batal),
              ),
            ),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        _showBluetoothPicker();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = AppLocalizations.of(context)!;
    final initials = _getInitials(auth.nama);
    final patientId = auth.patientId.isNotEmpty ? auth.patientId : 'PED-0000';
    final deviceName = auth.deviceName.isNotEmpty ? auth.deviceName : 'Galaxy Watch 4';

    final bool isProfileEmpty = auth.nama.isEmpty && auth.usia.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF4FC3F7)),
            SizedBox(height: 16),
            Text(
              'Menyimpan...',
              style: TextStyle(
                color: Color(0xFF1B3A5C),
                fontSize: 14,
              ),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 40),
            decoration: const BoxDecoration(
              color: Color(0xFF1B3A5C),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    lang.profilAnak,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _isEditing ? Icons.close : Icons.edit_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {
                    if (_isEditing) {
                      _loadDataFromAuth();
                    }
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -36),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isProfileEmpty ? Colors.grey.shade300 : const Color(0xFF2E5A8A),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      isProfileEmpty ? '?' : initials,
                      style: TextStyle(
                        color: isProfileEmpty ? Colors.grey.shade600 : const Color(0xFF4FC3F7),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isEditing ? _namaController.text : (auth.nama.isNotEmpty ? auth.nama : lang.belumDiisi),
                  style: TextStyle(
                    color: auth.nama.isNotEmpty ? const Color(0xFF1B3A5C) : Colors.grey.shade500,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _isEditing
                      ? '${_usiaController.text} ${lang.tahun}'
                      : (auth.usia.isNotEmpty ? '${auth.usia} ${lang.tahun}' : ''),
                  style: TextStyle(
                    color: auth.usia.isNotEmpty ? const Color(0xFF94A3B8) : Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _copyPatientId(patientId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isProfileEmpty ? Colors.grey.shade300 : const Color(0xFF1B3A5C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lang.kodeUnikPasien,
                          style: TextStyle(
                            color: isProfileEmpty ? Colors.grey.shade600 : const Color(0xFF4FC3F7),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isProfileEmpty ? lang.belumAda : patientId,
                          style: TextStyle(
                            color: isProfileEmpty ? Colors.grey.shade600 : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (!isProfileEmpty) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.copy,
                            color: Colors.white.withOpacity(0.6),
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isProfileEmpty ? Colors.grey.shade200 : const Color(0xFFEFF8FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isProfileEmpty ? Colors.grey.shade300 : const Color(0xFF4FC3F7),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.watch,
                        color: isProfileEmpty ? Colors.grey.shade500 : const Color(0xFF4FC3F7),
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isProfileEmpty
                            ? lang.belumTerhubung
                            : (auth.watchConnected ? deviceName : lang.tidakTerhubung),
                        style: TextStyle(
                          color: isProfileEmpty ? Colors.grey.shade500 : const Color(0xFF4FC3F7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0E1E3C).withOpacity(0.07)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isProfileEmpty && !_isEditing) ...[
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_add,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              lang.profilKosong,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lang.klikEdit,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_isEditing) ...[
                      _buildEditForm(lang),
                    ] else ...[
                      _buildProfileView(auth, lang),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(AppLocalizations lang) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.dataDiri.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildEditField(lang.namaLengkap, _namaController),
          const SizedBox(height: 4),
          Text(
            lang.minimal2Huruf,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          _buildEditField('${lang.usia} (${lang.tahun})', _usiaController),
          const SizedBox(height: 4),
          Text(
            lang.hanyaAngka,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          _buildEditField('${lang.bb} (kg)', _bbController),
          const SizedBox(height: 4),
          Text(
            lang.hanyaAngka,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          _buildEditField('${lang.tb} (cm)', _tbController),
          const SizedBox(height: 4),
          Text(
            lang.hanyaAngka,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang.goldar,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGoldar,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: _goldarOptions.map((goldar) {
                      return DropdownMenuItem(
                        value: goldar,
                        child: Text(goldar),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedGoldar = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          Text(
            lang.riwayatKondisi.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _kondisiController,
                  style: const TextStyle(color: Color(0xFF1B3A5C), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: lang.tambahKondisi,
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF1B3A5C), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                  onSubmitted: (_) => _addKondisi(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3A5C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _addKondisi,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _riwayatKondisi.asMap().entries.map((entry) {
              int index = entry.key;
              String label = entry.value;
              final data = _bubbleData[index % _bubbleData.length];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: data['bg'],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (data['color'] as Color).withOpacity(0.19),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: data['color'] as Color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _removeKondisi(index),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (_riwayatKondisi.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                lang.belumAdaKondisi,
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B3A5C),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                lang.simpanPerubahan,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView(AuthProvider auth, AppLocalizations lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(lang.dataDiri, lang),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildDataItem(
                value: auth.usia.isNotEmpty ? '${auth.usia} ${lang.tahun}' : '-',
                label: lang.usia,
              ),
              _buildDataItem(
                value: auth.bb.isNotEmpty ? '${auth.bb} kg' : '-',
                label: lang.bb,
              ),
              _buildDataItem(
                value: auth.tb.isNotEmpty ? '${auth.tb} cm' : '-',
                label: lang.tb,
              ),
              _buildDataItem(
                value: auth.goldar.isNotEmpty ? auth.goldar : '-',
                label: lang.goldar,
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 1),
        _buildSectionHeader(lang.riwayatKondisi, lang),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _riwayatKondisi.asMap().entries.map((entry) {
              int index = entry.key;
              String label = entry.value;
              final data = _bubbleData[index % _bubbleData.length];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: data['bg'],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (data['color'] as Color).withOpacity(0.19),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: data['color'] as Color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_riwayatKondisi.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              lang.belumAdaKondisi,
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 1),
        _buildSectionHeader(lang.pengaturanAlert, lang),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildAlertToggle(
                title: 'Alert SpO₂',
                subtitle: '${lang.notifJika} SpO₂ < 94%',
                value: auth.alertSpO2,
                onChanged: (value) {
                  _showAlertToggleDialog('SpO₂', auth.alertSpO2, (newValue) {
                    context.read<AuthProvider>().updateProfile({'alertSpO2': newValue});
                  });
                },
              ),
              const SizedBox(height: 4),
              _buildAlertToggle(
                title: 'Alert ${lang.heartRate}',
                subtitle: '${lang.notifJika} HR > 140 bpm',
                value: auth.alertHR,
                onChanged: (value) {
                  _showAlertToggleDialog('HR', auth.alertHR, (newValue) {
                    context.read<AuthProvider>().updateProfile({'alertHR': newValue});
                  });
                },
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 1),
        _buildSectionHeader(lang.smartwatch, lang),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: auth.watchConnected
                  ? Colors.green.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: auth.watchConnected
                    ? Colors.green.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  auth.watchConnected ? Icons.check_circle : Icons.bluetooth,
                  color: auth.watchConnected ? Colors.green : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.watchConnected ? auth.deviceName : lang.tidakAdaPerangkat,
                        style: TextStyle(
                          color: auth.watchConnected ? const Color(0xFF1B3A5C) : Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (auth.watchConnected)
                        Text(
                          '${lang.baterai} ${auth.watchBattery}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      if (!auth.watchConnected)
                        Text(
                          lang.klikHubungkan,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (auth.watchConnected)
                  GestureDetector(
                    onTap: _showSmartwatchDisconnectDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Text(
                        lang.putuskan,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (!auth.watchConnected)
                  GestureDetector(
                    onTap: _showBluetoothPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B3A5C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        lang.hubungkan,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String label, AppLocalizations lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDataItem({
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1B3A5C),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(
            color: Color(0xFF1B3A5C),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1B3A5C), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertToggle({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1B3A5C),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF1B3A5C),
        ),
      ],
    );
  }
}