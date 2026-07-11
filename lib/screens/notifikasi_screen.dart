// screens/notifikasi_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notifikasi_provider.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<NotifikasiProvider>(
        builder: (context, provider, child) {
          final belumDibaca = provider.getBelumDibaca();
          final sudahDibaca = provider.getSudahDibaca();
          final totalBelumDibaca = provider.belumDibaca;

          return Column(
            children: [
              // ========== HEADER ==========
              Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B3A5C),
                ),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Notifikasi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (totalBelumDibaca > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$totalBelumDibaca',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    // 🔥 TOMBOL TANDAI SEMUA
                    if (totalBelumDibaca > 0)
                      GestureDetector(
                        onTap: () {
                          provider.markAllAsRead();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Semua notifikasi ditandai telah dibaca'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Tandai Semua',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ========== BODY ==========
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ========== BELUM DIBACA ==========
                      if (belumDibaca.isNotEmpty) ...[
                        Text(
                          'BELUM DIBACA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...belumDibaca.map((notif) => _buildNotifikasiCard(
                          notif,
                          isRead: false,
                          onTap: () {
                            provider.markAsRead(notif['id'] as String);
                          },
                        )),
                        const SizedBox(height: 16),
                      ],

                      // ========== SUDAH DIBACA ==========
                      if (sudahDibaca.isNotEmpty) ...[
                        Text(
                          'SUDAH DIBACA',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...sudahDibaca.map((notif) => _buildNotifikasiCard(
                          notif,
                          isRead: true,
                        )),
                      ],

                      if (belumDibaca.isEmpty && sudahDibaca.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Column(
                              children: [
                                Icon(Icons.notifications_off, color: Color(0xFF94A3B8), size: 48),
                                SizedBox(height: 12),
                                Text(
                                  'Tidak ada notifikasi',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotifikasiCard(
      Map<String, dynamic> notif, {
        required bool isRead,
        VoidCallback? onTap,
      }) {
    // Tentukan warna berdasarkan tipe
    String title = notif['title'] as String;
    Color statusColor;
    Color bgColor;

    if (title.contains('Kritis') || title.contains('kritis')) {
      statusColor = const Color(0xFFEF4444); // Red
      bgColor = const Color(0xFFFFF5F5);
    } else if (title.contains('Tinggi') || title.contains('tinggi') || title.contains('Warning')) {
      statusColor = const Color(0xFFF59E0B); // Amber
      bgColor = const Color(0xFFFFFBEB);
    } else {
      statusColor = const Color(0xFF4FC3F7); // Cyan
      bgColor = const Color(0xFFEFF8FF);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? const Color(0xFF0E1E3C).withOpacity(0.07)
                : statusColor.withOpacity(0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(0),
              child: Icon(
                Icons.notifications_active,
                color: statusColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif['title'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B3A5C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notif['body'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif['time'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            // Badge belum dibaca
            if (!isRead)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}