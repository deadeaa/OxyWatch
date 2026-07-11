// screens/onboarding_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class OnboardingProfileScreen extends StatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  State<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  int _currentStep = 0;

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

  // Daftar Golongan Darah
  final List<String> _goldarOptions = [
    'A+', 'A-', 'B+', 'B-',
    'O+', 'O-', 'AB+', 'AB-'
  ];

  // Daftar perangkat Bluetooth dummy
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

  void _saveProfile({bool connectWatch = false, String deviceName = ''}) {
    if (!_isValidName(_namaController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama harus minimal 2 huruf dan tidak boleh kosong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_isNumeric(_usiaController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usia harus berupa angka'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_isNumeric(_bbController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('BB harus berupa angka'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_isNumeric(_tbController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('TB harus berupa angka'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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
      patientId: '',
    );

    if (connectWatch && deviceName.isNotEmpty) {
      authProvider.connectWatch();
      authProvider.updateProfile({'deviceName': deviceName});
    }

    authProvider.setProfileCompleted(true);

    // 🔥 LANGSUNG KE DASHBOARD - TANPA KONDISI
    Navigator.pushReplacementNamed(context, '/main');
  }

  void _skip() {
    final authProvider = context.read<AuthProvider>();
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
    Navigator.pushReplacementNamed(context, '/main');
  }

  // 🔥 SHOW BLUETOOTH DEVICE PICKER - VERSI PALING SIMPEL
  void _showBluetoothPicker() {
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Pilih Perangkat Bluetooth',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B3A5C),
                      ),
                    ),
                  ),
                  const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                  ListTile(
                    leading: const Icon(Icons.search, color: Color(0xFF4FC3F7)),
                    title: const Text(
                      'Cari Perangkat Baru',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B3A5C),
                      ),
                    ),
                    subtitle: const Text(
                      'Scan untuk mencari perangkat terdekat',
                      style: TextStyle(
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
                      // 🔥 TUTUP BOTTOM SHEET
                      Navigator.pop(context);

                      // 🔥 LANGSUNG SAVE + NAVIGASI - TANPA SETSTATE, TANPA DELAY
                      _saveProfile(
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
            const Text(
              'Mencari perangkat...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B3A5C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pastikan Bluetooth aktif',
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
                child: const Text('Batal'),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Lengkapi Profil'),
        backgroundColor: const Color(0xFF1B3A5C),
        actions: [
          TextButton(
            onPressed: _skip,
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                _buildStepIndicator(0, 'Data Diri'),
                _buildStepLine(),
                _buildStepIndicator(1, 'Riwayat'),
                _buildStepLine(),
                _buildStepIndicator(2, 'Alert'),
                _buildStepLine(),
                _buildStepIndicator(3, 'Connect'),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildDataDiriStep();
      case 1:
        return _buildRiwayatStep();
      case 2:
        return _buildAlertStep();
      case 3:
        return _buildConnectStep();
      default:
        return const SizedBox();
    }
  }

  // ========== STEP 1: DATA DIRI ==========
  Widget _buildDataDiriStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Diri Anak',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3A5C),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Isi data diri anak untuk memulai monitoring',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Nama Lengkap', _namaController),
                    const SizedBox(height: 4),
                    Text(
                      'Minimal 2 huruf',
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
                          _buildTextField('Usia (tahun)', _usiaController, keyboardType: TextInputType.number),
                          const SizedBox(height: 4),
                          Text(
                            'Hanya angka',
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
                          _buildTextField('BB (kg)', _bbController, keyboardType: TextInputType.number),
                          const SizedBox(height: 4),
                          Text(
                            'Hanya angka',
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
                          _buildTextField('TB (cm)', _tbController, keyboardType: TextInputType.number),
                          const SizedBox(height: 4),
                          Text(
                            'Hanya angka',
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
                          const Text(
                            'Gol. Darah',
                            style: TextStyle(
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
              if (!_isValidName(_namaController.text.trim())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nama harus minimal 2 huruf'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              if (!_isNumeric(_usiaController.text.trim())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usia harus berupa angka'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              if (!_isNumeric(_bbController.text.trim())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('BB harus berupa angka'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              if (!_isNumeric(_tbController.text.trim())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('TB harus berupa angka'),
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
            child: const Text('Next →', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  // ========== STEP 2: RIWAYAT KONDISI ==========
  Widget _buildRiwayatStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Kondisi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3A5C),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tambahkan riwayat kondisi kesehatan anak',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _kondisiController,
                style: const TextStyle(color: Color(0xFF1B3A5C)),
                decoration: InputDecoration(
                  hintText: 'Tambah kondisi...',
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Belum ada kondisi tambahan',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
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
                child: Text('← Back', style: TextStyle(color: Colors.grey.shade700)),
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
                child: const Text('Next →', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========== STEP 3: PENGATURAN ALERT ==========
  Widget _buildAlertStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pengaturan Alert',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3A5C),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Atur notifikasi peringatan kesehatan',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAlertToggle(
                  'Alert SpO₂',
                  'Notif jika SpO₂ < 94%',
                  _alertSpO2,
                      (value) => setState(() => _alertSpO2 = value),
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 24),
                _buildAlertToggle(
                  'Alert Detak Jantung',
                  'Notif jika HR > 140 bpm',
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
                child: Text('← Back', style: TextStyle(color: Colors.grey.shade700)),
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
                child: const Text('Next →', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========== STEP 4: CONNECT SMARTWATCH ==========
  Widget _buildConnectStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connect Smartwatch',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3A5C),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Hubungkan smartwatch untuk monitoring real-time',
          style: TextStyle(color: Colors.grey, fontSize: 13),
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
                            const Text(
                              'Cari Perangkat Bluetooth',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _selectedDevice.isNotEmpty
                                  ? 'Terhubung ke: $_selectedDevice'
                                  : 'Klik tombol di bawah untuk mencari perangkat',
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
                          'Pastikan Bluetooth aktif dan smartwatch dalam mode pairing',
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
                          'Kamu bisa skip dan menghubungkan nanti di halaman Profil',
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
                        child: Text('← Back', style: TextStyle(color: Colors.grey.shade700)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _saveProfile(connectWatch: false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Skip Connect', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isConnecting
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
                              _isConnecting ? 'Mencari...' : 'Connect',
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