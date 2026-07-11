// screens/pengaturan_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  String _selectedLanguage = 'id';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isProfileEmpty = auth.nama.isEmpty && auth.usia.isEmpty;
    final patientId = auth.patientId.isNotEmpty ? auth.patientId : 'PED-0000';

    // 🔥 AMBIL DEVICE NAME DARI AUTH (SAMA KAYAK PROFIL & DASHBOARD)
    final deviceName = auth.deviceName.isNotEmpty ? auth.deviceName : 'Galaxy Watch 4';

    String initials = '?';
    if (auth.nama.isNotEmpty) {
      final parts = auth.nama.trim().split(' ');
      if (parts.length >= 2) {
        initials = parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
      } else {
        initials = auth.nama.substring(0, 2).toUpperCase();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1B3A5C),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ========== HEADER PROFIL ==========
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isProfileEmpty ? Colors.grey.shade300 : const Color(0xFF1B3A5C),
                  child: Text(
                    isProfileEmpty ? '?' : initials,
                    style: TextStyle(
                      color: isProfileEmpty ? Colors.grey.shade600 : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isProfileEmpty ? 'Belum ada profil' : auth.nama,
                        style: TextStyle(
                          color: isProfileEmpty ? Colors.grey.shade400 : const Color(0xFF1B3A5C),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        isProfileEmpty ? '-' : patientId,
                        style: TextStyle(
                          color: isProfileEmpty ? Colors.grey.shade300 : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            auth.watchConnected ? Icons.watch : Icons.watch_outlined,
                            color: auth.watchConnected ? Colors.green : Colors.grey.shade400,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          // 🔥 DEVICE NAME SAMA KAYAK PROFIL & DASHBOARD
                          Text(
                            auth.watchConnected
                                ? '$deviceName · Baterai ${auth.watchBattery}'
                                : 'Belum terhubung',
                            style: TextStyle(
                              color: auth.watchConnected ? Colors.green : Colors.grey.shade400,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: auth.watchConnected
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    auth.watchConnected ? 'Terhubung' : 'Tidak terhubung',
                    style: TextStyle(
                      color: auth.watchConnected ? Colors.green : Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ========== PENGATURAN ==========
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PENGATURAN',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // ========== LANGUAGE TOGGLE ==========
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bahasa / Language',
                            style: TextStyle(
                              color: Color(0xFF1B3A5C),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'Ubah bahasa tampilan',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _buildLanguageButton('id', 'ID'),
                          _buildLanguageButton('en', 'EN'),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(color: Color(0xFFF1F5F9), height: 24),

                // ========== NOTIFIKASI KLINIS ==========
                _buildSettingRow(
                  title: 'Notifikasi klinis',
                  onTap: () {},
                ),

                const Divider(color: Color(0xFFF1F5F9), height: 16),

                // ========== PRIVASI DATA ANAK ==========
                _buildSettingRow(
                  title: 'Privasi data anak',
                  onTap: () {},
                ),

                const Divider(color: Color(0xFFF1F5F9), height: 16),

                // ========== BANTUAN & FAQ ==========
                _buildSettingRow(
                  title: 'Bantuan & FAQ',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ========== HAPUS PROFIL ==========
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showDeleteConfirmation(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Hapus Profil',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String code, String label) {
    final isSelected = _selectedLanguage == code;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bahasa diubah ke ${code == 'id' ? 'Indonesia' : 'English'}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B3A5C) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1B3A5C),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFF94A3B8),
            size: 16,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Hapus Profil?',
          style: TextStyle(
            color: Color(0xFF1B3A5C),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Semua data anak akan dihapus permanen. Yakin ingin melanjutkan?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Profil berhasil dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}