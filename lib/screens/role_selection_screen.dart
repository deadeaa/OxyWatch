import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../models/user_model.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/languages.dart';
import '../screens/login_screen.dart';
import '../screens/doctor_login_screen.dart';
import '../widgets/oxywatch_logo.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final languageProvider = context.watch<LanguageProvider>();
    final currentLang = languageProvider.currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Top area with logo
            Container(
              padding: const EdgeInsets.only(top: 32, bottom: 24),
              child: Stack(
                children: [
                  // Language toggle - TOP RIGHT
                  Positioned(
                    top: 4,
                    right: 20,
                    child: Container(
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
                  ),
                  // Logo and title - CENTER
                  Center(
                    child: Column(
                      children: [
                        const OxyWatchLogo(size: 64),
                        const SizedBox(height: 12),
                        Text(
                          'OxyWatch',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lang.locale.languageCode == 'id'
                              ? 'AI monitoring untuk si kecil'
                              : 'AI monitoring for your child',
                          style: const TextStyle(
                            color: Color(0xFFA9B7CC),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // White card
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.whoAreYou,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lang.selectRole,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Role: Parent - 🔥 LANGSUNG KE LOGIN
                    _buildRoleCard(
                      icon: Icons.person_outline,
                      title: lang.imParent,
                      subtitle: lang.parentSubtitle,
                      isHighlighted: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    // Role: Doctor - 🔥 KE DOCTOR LOGIN
                    _buildRoleCard(
                      icon: Icons.medical_services_outlined,
                      title: lang.imDoctor,
                      subtitle: lang.doctorSubtitle,
                      isHighlighted: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorLoginScreen(
                              onBack: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    // Footer note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4FC3F7).withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.show_chart,
                            color: AppColors.primaryLight,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lang.aiInfo,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                height: 1.5,
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
          ],
        ),
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

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isHighlighted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xFF1B3A5C)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHighlighted
                ? Colors.transparent
                : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? const Color(0xFF4FC3F7).withOpacity(0.15)
                    : const Color(0xFF1B3A5C).withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isHighlighted
                    ? const Color(0xFF4FC3F7)
                    : AppColors.textPrimary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isHighlighted
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isHighlighted
                          ? const Color(0xFFA9B7CC)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isHighlighted
                  ? const Color(0xFF4FC3F7)
                  : AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}