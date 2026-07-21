// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notifikasi_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/patient_card.dart';
import '../widgets/risk_score_card.dart';
import '../widgets/trend_chart.dart';
import '../screens/emergency_monitor_screen.dart';
import '../screens/notifikasi_screen.dart';
import '../screens/pengaturan_screen.dart';
import '../screens/login_screen.dart';
import '../utils/languages.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah kamu yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    // Pakai AuthProvider (bukan AuthService langsung) supaya semua state
    // (isLoggedIn, currentUser, data profil anak, dst) ikut ter-reset.
    await context.read<AuthProvider>().logout();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = AppLocalizations.of(context)!;
    final isProfileEmpty = auth.nama.isEmpty && auth.usia.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(lang.dashboard),
        backgroundColor: const Color(0xFF1B3A5C),
        elevation: 0,
        actions: [
          // 🔥 NOTIFIKASI - BADGE HANYA MUNCUL KALAU ADA PROFIL
          Consumer<NotifikasiProvider>(
            builder: (context, notifProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotifikasiScreen(),
                        ),
                      );
                    },
                  ),
                  // 🔥 BADGE HANYA MUNCUL KALAU:
                  // 1. Profil TIDAK kosong
                  // 2. Ada notifikasi belum dibaca
                  if (!isProfileEmpty && notifProvider.belumDibaca > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '${notifProvider.belumDibaca}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PengaturanScreen(),
                ),
              );
            },
          ),
          // 🔥 TOMBOL LOGOUT (baru ditambahkan)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PatientCard(),
              const SizedBox(height: 16),

              // Vital Signs Row
              Row(
                children: [
                  Expanded(
                    child: _buildVitalCard(
                      title: lang.spo2,
                      value: isProfileEmpty ? '-' : '98',
                      unit: isProfileEmpty ? '' : '%',
                      status: isProfileEmpty ? lang.belumAdaData : lang.normal,
                      statusColor: isProfileEmpty ? Colors.grey : Colors.green,
                      icon: Icons.bloodtype,
                      isEmpty: isProfileEmpty,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVitalCard(
                      title: lang.heartRate,
                      value: isProfileEmpty ? '-' : '105',
                      unit: isProfileEmpty ? '' : 'bpm',
                      status: isProfileEmpty ? lang.belumAdaData : lang.normal,
                      statusColor: isProfileEmpty ? Colors.grey : Colors.green,
                      icon: Icons.favorite,
                      isEmpty: isProfileEmpty,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Risk Score Card
              isProfileEmpty
                  ? _buildEmptyCard(lang.belumAdaRiskScore)
                  : const RiskScoreCard(),
              const SizedBox(height: 16),

              // 🔥 TREND CHART
              const TrendChart(),
              const SizedBox(height: 16),

              // Tombol Emergency
              GestureDetector(
                onTap: isProfileEmpty
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyMonitorScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isProfileEmpty ? Colors.grey.shade200 : const Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isProfileEmpty ? Colors.grey.shade300 : const Color(0xFFEF4444),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: isProfileEmpty ? Colors.grey.shade400 : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isProfileEmpty ? lang.fillProfileFirst : lang.emergencyLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isProfileEmpty ? Colors.grey.shade500 : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalCard({
    required String title,
    required String value,
    required String unit,
    required String status,
    required Color statusColor,
    required IconData icon,
    required bool isEmpty,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isEmpty ? Colors.grey.shade400 : const Color(0xFF1B3A5C), size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isEmpty ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isEmpty ? Colors.grey.shade400 : const Color(0xFF1B3A5C),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: isEmpty ? Colors.grey.shade400 : Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}