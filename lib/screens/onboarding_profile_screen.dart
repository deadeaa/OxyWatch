import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../utils/languages.dart';
import '../config/app_colors.dart';

class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  State<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Data Diri
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usiaController = TextEditingController();
  final TextEditingController _bbController = TextEditingController();
  final TextEditingController _tbController = TextEditingController();
  String _selectedGoldar = 'A+';

  // Riwayat Kondisi
  final List<String> _riwayatKondisi = [];
  final TextEditingController _kondisiController = TextEditingController();

  // Alert Settings
  bool _alertSpO2 = true;
  bool _alertHR = true;

  // Connect Smartwatch
  bool _isConnecting = false;
  String _selectedDevice = '';

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

  @override
  void dispose() {
    _namaController.dispose();
    _usiaController.dispose();
    _bbController.dispose();
    _tbController.dispose();
    _kondisiController.dispose();
    super.dispose();
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

  bool _isValidName(String name) {
    final trimmed = name.trim();
    return trimmed.length >= 2 && trimmed.split(' ').every((word) => word.isNotEmpty);
  }

  bool _isNumeric(String value) {
    return double.tryParse(value) != null && double.parse(value) > 0;
  }

  // ========== SAVE TO FIREBASE ==========
  Future<void> _saveProfileToFirebase({
    bool connectWatch = false,
    String deviceName = '',
  }) async {
    final lang = AppLocalizations.of(context)!;

    if (_namaController.text.trim().isNotEmpty) {
      if (!_isValidName(_namaController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.namaMinimal2),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    if (_usiaController.text.trim().isNotEmpty) {
      if (!_isNumeric(_usiaController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.usiaHarusAngka),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    if (_bbController.text.trim().isNotEmpty) {
      if (!_isNumeric(_bbController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.bbHarusAngka),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    if (_tbController.text.trim().isNotEmpty) {
      if (!_isNumeric(_tbController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.tbHarusAngka),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final String patientId = 'PED-${DateTime.now().millisecondsSinceEpoch.toString().substring(7, 12)}';

      final profileData = {
        'uid': user.uid,
        'nama': _namaController.text.trim(),
        'usia': _usiaController.text.trim(),
        'bb': _bbController.text.trim(),
        'tb': _tbController.text.trim(),
        'goldar': _selectedGoldar,
        'riwayat': _riwayatKondisi,
        'alertSpO2': _alertSpO2,
        'alertHR': _alertHR,
        'patientId': patientId,
        'deviceName': connectWatch ? deviceName : '',
        'watchConnected': connectWatch,
        'watchBattery': '100%',
        'profileCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(
        profileData,
        SetOptions(merge: true),
      );

      final authProvider = context.read<AuthProvider>();
      authProvider.setProfile(
        nama: _namaController.text.trim(),
        usia: _usiaController.text.trim(),
        bb: _bbController.text.trim(),
        tb: _tbController.text.trim(),
        goldar: _selectedGoldar,
        riwayat: _riwayatKondisi,
        alertSpO2: _alertSpO2,
        alertHR: _alertHR,
        patientId: patientId,
      );

      if (connectWatch && deviceName.isNotEmpty) {
        authProvider.connectWatch();
        authProvider.updateProfile({'deviceName': deviceName});
      }

      authProvider.setProfileCompleted(true);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${lang.profilBerhasil}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal menyimpan profil: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ========== SKIP ==========
  Future<void> _skip() async {
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final authProvider = context.read<AuthProvider>();

      final profileData = {
        'uid': user.uid,
        'nama': '',
        'usia': '',
        'bb': '',
        'tb': '',
        'goldar': '',
        'riwayat': [],
        'alertSpO2': true,
        'alertHR': true,
        'patientId': 'PED-0000',
        'deviceName': '',
        'watchConnected': false,
        'watchBattery': '0%',
        'profileCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(
        profileData,
        SetOptions(merge: true),
      );

      authProvider.setProfile(
        nama: '',
        usia: '',
        bb: '',
        tb: '',
        goldar: '',
        riwayat: [],
        alertSpO2: true,
        alertHR: true,
        patientId: 'PED-0000',
      );
      authProvider.setProfileCompleted(true);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal skip: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ========== BLUETOOTH PICKER ==========
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
                      lang.pilihPerangkat,
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
                      lang.cariPerangkatBaru,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B3A5C),
                      ),
                    ),
                    subtitle: Text(
                      lang.scanPerangkat,
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
                      _saveProfileToFirebase(
                        connectWatch: true,
                        deviceName: device['name']!,
                      );
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
              lang.mencari,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B3A5C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lang.pastikanBluetooth,
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
    final lang = AppLocalizations.of(context)!;
    final languageProvider = context.watch<LanguageProvider>();
    final currentLang = languageProvider.currentLanguage;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(lang.lengkapiProfil),
        backgroundColor: AppColors.primary,
        actions: [
          // Language toggle
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildLangButton('id', 'ID', currentLang, context),
                _buildLangButton('en', 'EN', currentLang, context),
              ],
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: _isLoading ? null : _skip,
            child: Text(
              lang.skip,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF4FC3F7)),
            SizedBox(height: 16),
            Text(
              'Menyimpan profil...',
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                _buildStepIndicator(0, lang.dataDiriAnak),
                _buildStepLine(),
                _buildStepIndicator(1, lang.riwayatKondisi),
                _buildStepLine(),
                _buildStepIndicator(2, lang.pengaturanAlert),
                _buildStepLine(),
                _buildStepIndicator(3, lang.connectSmartwatch),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(lang),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangButton(
      String code,
      String label,
      String currentLang,
      BuildContext context,
      ) {
    final isSelected = currentLang == code;
    final languageProvider = context.read<LanguageProvider>();
    final authProvider = context.read<AuthProvider>();

    return GestureDetector(
      onTap: () {
        languageProvider.setLanguage(code);
        authProvider.updateUserLanguage(code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  // ... (rest of the code remains the same as previous)
  Widget _buildStepIndicator(int index, String label) {
    bool isActive = _currentStep == index;
    bool isDone = _currentStep > index;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive || isDone ? const Color(0xFF1B3A5C) : Colors.grey.shade300,
            ),
            child: Center(
              child: Text(
                isDone ? '✓' : '${index + 1}',
                style: TextStyle(
                  color: isActive || isDone ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? const Color(0xFF1B3A5C) : Colors.grey.shade400,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 20,
      height: 2,
      color: _currentStep > 0 ? const Color(0xFF1B3A5C) : Colors.grey.shade300,
    );
  }

  Widget _buildStepContent(AppLocalizations lang) {
    switch (_currentStep) {
      case 0:
        return _buildDataDiriStep(lang);
      case 1:
        return _buildRiwayatStep(lang);
      case 2:
        return _buildAlertStep(lang);
      case 3:
        return _buildConnectStep(lang);
      default:
        return const SizedBox();
    }
  }

  // ========== STEP 1: DATA DIRI ==========
  Widget _buildDataDiriStep(AppLocalizations lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.dataDiriAnak,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3A5C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lang.isiDataDiri,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(lang.namaLengkap, _namaController),
                    const SizedBox(height: 4),
                    Text(
                      lang.minimal2Huruf,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField('${lang.usia} (${lang.tahun})', _usiaController, keyboardType: TextInputType.number),
                          const SizedBox(height: 4),
                          Text(
                            lang.hanyaAngka,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField('${lang.bb} (kg)', _bbController, keyboardType: TextInputType.number),
                          const SizedBox(height: 4),
                          Text(
                            lang.hanyaAngka,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField('${lang.tb} (cm)', _tbController, keyboardType: TextInputType.number),
                          const SizedBox(height: 4),
                          Text(
                            lang.hanyaAngka,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.goldar,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
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
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_namaController.text.trim().isNotEmpty && !_isValidName(_namaController.text.trim())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(lang.namaMinimal2),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              setState(() => _currentStep = 1);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B3A5C),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              lang.next,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ========== STEP 2: RIWAYAT KONDISI ==========
  Widget _buildRiwayatStep(AppLocalizations lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.riwayatKondisi,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3A5C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lang.tambahkanRiwayat,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _kondisiController,
                style: const TextStyle(color: Color(0xFF1B3A5C)),
                decoration: InputDecoration(
                  hintText: lang.tambahKondisi,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1B3A5C)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: Colors.white,
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
        const SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _riwayatKondisi.asMap().entries.map((entry) {
                int index = entry.key;
                String kondisi = entry.value;
                final colors = [
                  Color(0xFFD97706), Color(0xFF0EA5E9),
                  Color(0xFFEF4444), Color(0xFF8B5CF6),
                  Color(0xFFEC4899), Color(0xFF14B8A6)
                ];
                final color = colors[index % colors.length];
                return Chip(
                  label: Text(kondisi, style: TextStyle(fontSize: 13, color: color)),
                  backgroundColor: color.withOpacity(0.1),
                  deleteIcon: const Icon(Icons.close, size: 16, color: Colors.grey),
                  onDeleted: () => _removeKondisi(index),
                );
              }).toList(),
            ),
          ),
        ),
        if (_riwayatKondisi.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                lang.belumAdaKondisi,
                style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _currentStep = 0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  lang.back,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _currentStep = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3A5C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  lang.next,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========== STEP 3: PENGATURAN ALERT ==========
  Widget _buildAlertStep(AppLocalizations lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.pengaturanAlert,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3A5C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lang.aturNotifikasi,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAlertToggle(
                  'Alert SpO₂',
                  '${lang.notifJika} SpO₂ < 94%',
                  _alertSpO2,
                      (value) => setState(() => _alertSpO2 = value),
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 24),
                _buildAlertToggle(
                  'Alert ${lang.heartRate}',
                  '${lang.notifJika} HR > 140 bpm',
                  _alertHR,
                      (value) => setState(() => _alertHR = value),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  lang.back,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _currentStep = 3),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3A5C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  lang.next,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========== STEP 4: CONNECT SMARTWATCH ==========
  Widget _buildConnectStep(AppLocalizations lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.connectSmartwatch,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3A5C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lang.hubungkanSmartwatch,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bluetooth, color: Colors.blue.shade400, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.cariPerangkat,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _selectedDevice.isNotEmpty
                                  ? '${lang.terhubung} ke: $_selectedDevice'
                                  : lang.pastikanBluetooth,
                              style: TextStyle(
                                color: _selectedDevice.isNotEmpty
                                    ? Colors.green
                                    : Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedDevice.isNotEmpty)
                        const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade400, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lang.pastikanBluetooth,
                          style: TextStyle(
                            color: Colors.orange.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.skip_next, color: Colors.green.shade400, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lang.skipConnect,
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _currentStep = 2),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          lang.back,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _saveProfileToFirebase(connectWatch: false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          lang.skipConnectBtn,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading || _isConnecting
                            ? null
                            : () {
                          _showBluetoothPicker();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B3A5C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isConnecting)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              const Icon(Icons.bluetooth, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _isConnecting ? lang.mencari : lang.connect,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Color(0xFF1B3A5C), fontSize: 14),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1B3A5C), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
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