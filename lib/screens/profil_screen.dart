// screens/profil_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  bool _isEditing = false;

  late TextEditingController _namaController;
  late TextEditingController _usiaController;
  late TextEditingController _bbController;
  late TextEditingController _tbController;
  late TextEditingController _goldarController;
  List<String> _riwayatKondisi = [];
  final TextEditingController _kondisiController = TextEditingController();

  // 🔥 STATE UNTUK ALERT & SMARTWATCH
  bool _alertSpO2 = true;
  bool _alertHR = true;
  bool _watchConnected = false;
  String _selectedGoldar = 'A+';
  String _connectedDeviceName = '';

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

  void _saveEdit() {
    // 🔥 VALIDASI
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

    // 🔥 UPDATE KE AUTH
    final auth = context.read<AuthProvider>();
    auth.updateProfile({
      'nama': _namaController.text.trim(),
      'usia': _usiaController.text.trim(),
      'bb': _bbController.text.trim(),
      'tb': _tbController.text.trim(),
      'goldar': _selectedGoldar,
      'riwayat': _riwayatKondisi,
      'alertSpO2': _alertSpO2,
      'alertHR': _alertHR,
    });

    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Profil berhasil diperbarui'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 🔥 SHOW BLUETOOTH DEVICE PICKER
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
                      Navigator.pop(context);

                      // 🔥 CONNECT KE DEVICE YANG DIPILIH
                      final auth = context.read<AuthProvider>();
                      auth.connectWatch();
                      auth.updateProfile({'deviceName': device['name']});

                      // 🔥 UPDATE STATE
                      setState(() {
                        _watchConnected = true;
                        _connectedDeviceName = device['name']!;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ ${device['name']} berhasil terhubung!'),
                          backgroundColor: Colors.green,
                        ),
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
    final auth = context.watch<AuthProvider>();
    final initials = _getInitials(auth.nama);
    final patientId = auth.patientId.isNotEmpty ? auth.patientId : 'PED-0000';
    final deviceName = auth.deviceName.isNotEmpty ? auth.deviceName : 'Galaxy Watch 4';

    final bool isProfileEmpty = auth.nama.isEmpty && auth.usia.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          // ========== HEADER ==========
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
                const Expanded(
                  child: Text(
                    'Profil Anak',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                      // 🔥 BATAL EDIT - RELOAD DATA DARI AUTH
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

          // ========== AVATAR OVERLAPPING ==========
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
                  _isEditing ? _namaController.text : (auth.nama.isNotEmpty ? auth.nama : 'Belum diisi'),
                  style: TextStyle(
                    color: auth.nama.isNotEmpty ? const Color(0xFF1B3A5C) : Colors.grey.shade500,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _isEditing
                      ? '${_usiaController.text} tahun'
                      : (auth.usia.isNotEmpty ? '${auth.usia} tahun' : ''),
                  style: TextStyle(
                    color: auth.usia.isNotEmpty ? const Color(0xFF94A3B8) : Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isProfileEmpty ? Colors.grey.shade300 : const Color(0xFF1B3A5C),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'KODE UNIK PASIEN  ',
                        style: TextStyle(
                          color: isProfileEmpty ? Colors.grey.shade600 : const Color(0xFF4FC3F7),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        isProfileEmpty ? 'BELUM ADA' : patientId,
                        style: TextStyle(
                          color: isProfileEmpty ? Colors.grey.shade600 : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
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
                            ? 'Belum terhubung'
                            : (auth.watchConnected ? deviceName : 'Tidak terhubung'),
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

          // ========== BODY CARD ==========
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
                              'Profil masih kosong',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Klik ikon edit di atas untuk mengisi data diri',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_isEditing) ...[
                      // ========== EDIT MODE ==========
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DATA DIRI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildEditField('Nama Lengkap', _namaController),
                            const SizedBox(height: 4),
                            Text(
                              'Minimal 2 huruf',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildEditField('Usia (tahun)', _usiaController),
                            const SizedBox(height: 4),
                            Text(
                              'Hanya angka',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildEditField('BB (kg)', _bbController),
                            const SizedBox(height: 4),
                            Text(
                              'Hanya angka',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildEditField('TB (cm)', _tbController),
                            const SizedBox(height: 4),
                            Text(
                              'Hanya angka',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Gol. Darah Dropdown
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Gol. Darah',
                                  style: TextStyle(
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

                            // Riwayat Kondisi
                            const Text(
                              'RIWAYAT KONDISI',
                              style: TextStyle(
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
                                      hintText: 'Tambah kondisi...',
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
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  'Belum ada riwayat kondisi',
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
                                onPressed: _saveEdit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B3A5C),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  '💾 Simpan Perubahan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // ========== VIEW MODE ==========
                      _buildSectionHeader('Data Diri'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildDataItem(
                              value: auth.usia.isNotEmpty ? '${auth.usia} thn' : '-',
                              label: 'Usia',
                            ),
                            _buildDataItem(
                              value: auth.bb.isNotEmpty ? '${auth.bb} kg' : '-',
                              label: 'BB',
                            ),
                            _buildDataItem(
                              value: auth.tb.isNotEmpty ? '${auth.tb} cm' : '-',
                              label: 'TB',
                            ),
                            _buildDataItem(
                              value: auth.goldar.isNotEmpty ? auth.goldar : '-',
                              label: 'Gol. Darah',
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 1),

                      _buildSectionHeader('Riwayat Kondisi'),
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
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Belum ada riwayat kondisi',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 1),

                      // ========== PENGATURAN ALERT (LANGSUNG ON/OFF) ==========
                      _buildSectionHeader('Pengaturan Alert'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildAlertToggle(
                              title: 'Alert SpO₂',
                              subtitle: 'Notif jika SpO₂ < 94%',
                              value: auth.alertSpO2,
                              onChanged: (value) {
                                context.read<AuthProvider>().updateProfile({'alertSpO2': value});
                                setState(() {
                                  _alertSpO2 = value;
                                });
                              },
                            ),
                            const SizedBox(height: 4),
                            _buildAlertToggle(
                              title: 'Alert Detak Jantung',
                              subtitle: 'Notif jika HR > 140 bpm',
                              value: auth.alertHR,
                              onChanged: (value) {
                                context.read<AuthProvider>().updateProfile({'alertHR': value});
                                setState(() {
                                  _alertHR = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 1),

                      // ========== SMARTWATCH (LANGSUNG CONNECT/DISCONNECT) ==========
                      _buildSectionHeader('Smartwatch'),
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
                                      auth.watchConnected ? deviceName : 'Tidak ada perangkat terhubung',
                                      style: TextStyle(
                                        color: auth.watchConnected ? const Color(0xFF1B3A5C) : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (auth.watchConnected)
                                      Text(
                                        'Baterai ${auth.watchBattery}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    if (!auth.watchConnected)
                                      Text(
                                        'Klik tombol di bawah untuk mencari perangkat',
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
                                  onTap: () {
                                    final auth = context.read<AuthProvider>();
                                    auth.disconnectWatch();
                                    auth.updateProfile({'deviceName': ''});
                                    setState(() {
                                      _watchConnected = false;
                                      _connectedDeviceName = '';
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('❌ Smartwatch diputuskan'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                                    ),
                                    child: const Text(
                                      'Putuskan',
                                      style: TextStyle(
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
                                    child: const Text(
                                      'Hubungkan',
                                      style: TextStyle(
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
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