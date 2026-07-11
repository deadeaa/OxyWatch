// widgets/patient_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isProfileEmpty = auth.nama.isEmpty && auth.usia.isEmpty;

    String initials = '?';
    if (auth.nama.isNotEmpty) {
      final parts = auth.nama.trim().split(' ');
      if (parts.length >= 2) {
        initials = parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
      } else {
        initials = auth.nama.substring(0, 2).toUpperCase();
      }
    }

    final deviceName = auth.deviceName.isNotEmpty ? auth.deviceName : 'Galaxy Watch 4';

    if (isProfileEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B3A5C), Color(0xFF2E5A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B3A5C).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B3A5C),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Belum ada profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Isi profil anak terlebih dahulu',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 🔥 TAMPILAN JIKA ADA PROFIL - SEMUA DATA MUNCUL
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B3A5C), Color(0xFF2E5A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B3A5C).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B3A5C),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 🔥 MIDDLE SECTION - Info Pasien
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // NAMA - 1 baris, ellipsis
                Text(
                  auth.nama.isNotEmpty ? auth.nama : 'Belum diisi',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                // 🔥 USIA + BB + ID - 1 baris, pakai Wrap
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(
                      '${auth.usia.isNotEmpty ? auth.usia : '?'} tahun · ${auth.bb.isNotEmpty ? auth.bb : '?'} kg',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        auth.patientId.isNotEmpty ? auth.patientId : 'PED-0000',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 🔥 RIGHT SECTION - Status Watch
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Device name - 1 baris, ellipsis
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    auth.watchConnected ? Icons.watch : Icons.watch_outlined,
                    color: auth.watchConnected ? Colors.white : Colors.white.withOpacity(0.5),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: Text(
                      auth.watchConnected ? deviceName : 'Tidak terhubung',
                      style: TextStyle(
                        color: auth.watchConnected ? Colors.white : Colors.white.withOpacity(0.5),
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: auth.watchConnected
                      ? Colors.green.shade400.withOpacity(0.3)
                      : Colors.grey.shade400.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      auth.watchConnected ? Icons.check_circle : Icons.close,
                      color: auth.watchConnected ? Colors.white : Colors.white.withOpacity(0.5),
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      auth.watchConnected ? 'Terhubung' : 'Tidak terhubung',
                      style: TextStyle(
                        fontSize: 9,
                        color: auth.watchConnected ? Colors.white : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}