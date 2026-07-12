import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../utils/languages.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = AppLocalizations.of(context)!;
    final languageProvider = context.watch<LanguageProvider>();

    final isProfileEmpty = auth.nama.isEmpty && auth.usia.isEmpty;
    final patientId = auth.patientId.isNotEmpty ? auth.patientId : 'PED-0000';
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
        title: Text(
          lang.pengaturan,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1B3A5C),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF4FC3F7)),
      )
          : ListView(
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
                  backgroundColor:
                  isProfileEmpty ? Colors.grey.shade300 : const Color(0xFF1B3A5C),
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
                        isProfileEmpty ? lang.belumAdaProfil : auth.nama,
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
                          Text(
                            auth.watchConnected
                                ? '$deviceName  '
                                : lang.belumTerhubung,
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
                    auth.watchConnected ? lang.terhubung : lang.tidakTerhubung,
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
                Text(
                  lang.pengaturan.toUpperCase(),
                  style: const TextStyle(
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
                          Text(
                            lang.bahasa,
                            style: const TextStyle(
                              color: Color(0xFF1B3A5C),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            lang.ubahBahasa,
                            style: const TextStyle(
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
                          _buildLanguageButton('id', 'ID', languageProvider, context, auth),
                          _buildLanguageButton('en', 'EN', languageProvider, context, auth),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(color: Color(0xFFF1F5F9), height: 24),

                // ========== NOTIFIKASI KLINIS ==========
                _buildSettingRow(
                  title: lang.notifikasiKlinis,
                  onTap: () {},
                ),

                const Divider(color: Color(0xFFF1F5F9), height: 16),

                // ========== PRIVASI DATA ANAK ==========
                _buildSettingRow(
                  title: lang.privasiDataAnak,
                  onTap: () {},
                ),

                const Divider(color: Color(0xFFF1F5F9), height: 16),

                // ========== BANTUAN & FAQ ==========
                _buildSettingRow(
                  title: lang.bantuanFAQ,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ========== BUTTON LOGOUT ==========
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showLogoutConfirmation(context, lang);
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ========== HAPUS PROFIL ==========
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showDeleteConfirmation(context, lang);
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_outline, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    lang.hapusProfil,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ========== LANGUAGE BUTTON ==========
  Widget _buildLanguageButton(
      String code,
      String label,
      LanguageProvider lang,
      BuildContext context,
      AuthProvider auth,
      ) {
    final isSelected = lang.currentLanguage == code;
    return GestureDetector(
      onTap: () {
        lang.setLanguage(code);
        // 🔥 Save to Firebase
        auth.updateUserLanguage(code);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.translate, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    code == 'id'
                        ? '🌏 Bahasa diubah ke Indonesia'
                        : '🌏 Language changed to English',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    code.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1B3A5C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
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

  // ========== SETTING ROW ==========
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

  // ========== LOGOUT CONFIRMATION ==========
  void _showLogoutConfirmation(BuildContext context, AppLocalizations lang) {
    showDialog(
      context: context,
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
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFF1B3A5C),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin logout?',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
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
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
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

  // ========== DELETE CONFIRMATION ==========
  void _showDeleteConfirmation(BuildContext context, AppLocalizations lang) {
    showDialog(
      context: context,
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
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              lang.hapusProfil,
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
              lang.hapusProfilPermanen,
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
                    Icons.info_outline,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Semua data akan dihapus permanen',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
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
                await context.read<AuthProvider>().deleteProfile();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              lang.profilDihapus,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal menghapus profil: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                if (mounted) setState(() => _isLoading = false);
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
              lang.hapus,
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
}