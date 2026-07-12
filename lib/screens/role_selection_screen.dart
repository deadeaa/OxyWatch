// screens/role_selection_screen.dart
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/user_model.dart';
import '../screens/register_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _selectRole(BuildContext context, UserRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(role: role == UserRole.parent ? 'parent' : 'doctor'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF16233B),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.monitor_heart_outlined,
                size: 36,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'OxyWatch',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'AI monitoring untuk si kecil',
              style: TextStyle(color: Color(0xFFA9B7CC), fontSize: 14),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Siapa Anda?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pilih peran untuk melanjutkan ke halaman yang sesuai',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 28),
                      _RoleCard(
                        icon: Icons.person_outline,
                        title: 'Saya Orang Tua',
                        subtitle: 'Pantau kesehatan anak secara real-time',
                        highlighted: true,
                        onTap: () => _selectRole(context, UserRole.parent),
                      ),
                      const SizedBox(height: 16),
                      _RoleCard(
                        icon: Icons.medical_services_outlined,
                        title: 'Saya Dokter',
                        subtitle: 'Akses dashboard klinis & data pasien',
                        highlighted: false,
                        onTap: () => _selectRole(context, UserRole.doctor),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.show_chart,
                                color: AppColors.primaryLight, size: 20),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'OxyWatch menggunakan AI untuk pemantauan saturasi oksigen dan detak jantung anak secara real-time.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlighted;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: highlighted ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlighted ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: highlighted
                    ? Colors.white.withOpacity(0.12)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: highlighted ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: highlighted ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: highlighted
                          ? const Color(0xFFA9B7CC)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: highlighted ? Colors.white70 : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}