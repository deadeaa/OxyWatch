// screens/notifikasi_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notifikasi_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/monitoring_provider.dart';
import '../utils/languages.dart';
import '../screens/emergency_monitor_screen.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  // 🔥 ID NOTIFIKASI YANG SEDANG DIPROSES
  String? _processingNotifId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSmartwatchData();
    });
  }

  void _checkSmartwatchData() {
    final monitoring = context.read<MonitoringProvider>();
    final notifProvider = context.read<NotifikasiProvider>();

    if (monitoring.spo2 <= 90) {
      notifProvider.addNotification(
        title: '⚠️ SpO₂ Kritis!',
        body: 'SpO₂ turun ke ${monitoring.spo2}% — Segera periksa!',
        time: DateTime.now().toString().substring(11, 16),
        type: 'critical',
      );
      _showNotificationPopup(context, 'critical', monitoring.spo2, monitoring.heartRate);
    } else if (monitoring.spo2 < 94) {
      notifProvider.addNotification(
        title: '⚠️ SpO₂ Warning',
        body: 'SpO₂ ${monitoring.spo2}% — Perlu dipantau',
        time: DateTime.now().toString().substring(11, 16),
        type: 'warning',
      );
      _showNotificationPopup(context, 'warning', monitoring.spo2, monitoring.heartRate);
    }

    if (monitoring.heartRate > 150) {
      notifProvider.addNotification(
        title: '⚠️ Detak Jantung Tinggi!',
        body: 'HR mencapai ${monitoring.heartRate} bpm — Perlu perhatian!',
        time: DateTime.now().toString().substring(11, 16),
        type: 'critical',
      );
      _showNotificationPopup(context, 'critical', monitoring.spo2, monitoring.heartRate);
    } else if (monitoring.heartRate > 140) {
      notifProvider.addNotification(
        title: '⚠️ HR Warning',
        body: 'HR ${monitoring.heartRate} bpm — Perlu dipantau',
        time: DateTime.now().toString().substring(11, 16),
        type: 'warning',
      );
      _showNotificationPopup(context, 'warning', monitoring.spo2, monitoring.heartRate);
    }
  }

  // 🔥 SHOW NOTIFICATION POPUP - AUTO MARK AS READ SAAT DITUTUP/DILIHAT
  void _showNotificationPopup(BuildContext context, String type, int spo2, int hr) {
    final lang = AppLocalizations.of(context)!;
    final isCritical = type == 'critical';
    final isWarning = type == 'warning';
    final color = isCritical ? Colors.red : isWarning ? Colors.orange : Colors.blue;
    final title = isCritical ? '🚨 Kondisi Darurat!' : isWarning ? '⚠️ Peringatan' : 'ℹ️ Informasi';
    final body = isCritical
        ? 'SpO₂: ${spo2}% · HR: ${hr} bpm\nSegera lakukan tindakan!'
        : isWarning
        ? 'SpO₂: ${spo2}% · HR: ${hr} bpm\nPerlu pemantauan lebih lanjut'
        : 'Data vital dalam batas normal';

    // 🔥 AMBIL ID NOTIFIKASI TERBARU
    final notifProvider = context.read<NotifikasiProvider>();
    final latestNotif = notifProvider.getBelumDibaca().isNotEmpty
        ? notifProvider.getBelumDibaca().first
        : null;
    final notifId = latestNotif?['id'] as String?;

    showDialog(
      context: context,
      barrierDismissible: false,
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
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCritical ? Icons.warning_amber_rounded :
                isWarning ? Icons.warning :
                Icons.info_outline,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1B3A5C),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              body,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isCritical ? lang.segeraTindakan :
                      isWarning ? lang.perluDipantau :
                      lang.dataNormal,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
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
            onPressed: () {
              // 🔥 MARK AS READ SAAT TUTUP
              if (notifId != null) {
                context.read<NotifikasiProvider>().markAsRead(notifId);
              }
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              lang.tutup,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isCritical || isWarning)
            ElevatedButton(
              onPressed: () {
                // 🔥 MARK AS READ SEBELUM NAVIGASI
                if (notifId != null) {
                  context.read<NotifikasiProvider>().markAsRead(notifId);
                }
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyMonitorScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B3A5C),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                lang.bukaMonitor,
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

  // 🔥 DETAIL NOTIFIKASI - AUTO MARK AS READ
  void _showDetailNotifikasi(BuildContext context, Map<String, dynamic> notif) {
    final lang = AppLocalizations.of(context)!;
    final isCritical = notif['type'] == 'critical';
    final isWarning = notif['type'] == 'warning';
    final color = isCritical ? Colors.red : isWarning ? Colors.orange : Colors.blue;
    final notifId = notif['id'] as String;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCritical ? Icons.warning_amber_rounded :
                      isWarning ? Icons.warning :
                      Icons.info_outline,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          notif['time'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // 🔥 MARK AS READ SAAT CLOSE
                      context.read<NotifikasiProvider>().markAsRead(notifId);
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                notif['body'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1B3A5C),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCritical ? lang.kritis :
                  isWarning ? lang.warning :
                  lang.informasi,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // 🔥 MARK AS READ SAAT TUTUP
                        context.read<NotifikasiProvider>().markAsRead(notifId);
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        lang.tutup,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (isCritical || isWarning)
                    const SizedBox(width: 12),
                  if (isCritical || isWarning)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // 🔥 MARK AS READ SEBELUM NAVIGASI
                          context.read<NotifikasiProvider>().markAsRead(notifId);
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmergencyMonitorScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B3A5C),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          lang.bukaMonitor,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isProfileEmpty = auth.nama.isEmpty && auth.usia.isEmpty;
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: isProfileEmpty
          ? _buildEmptyProfileState(lang)
          : Consumer<NotifikasiProvider>(
        builder: (context, provider, child) {
          final belumDibaca = provider.getBelumDibaca();
          final sudahDibaca = provider.getSudahDibaca();
          final totalBelumDibaca = provider.belumDibaca;

          if (provider.getAllNotifikasi().isEmpty) {
            return _buildEmptyState(lang);
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B3A5C),
                ),
                child: Row(
                  children: [
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
                    Text(
                      lang.notifikasi,
                      style: const TextStyle(
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
                    if (totalBelumDibaca > 0)
                      GestureDetector(
                        onTap: () {
                          provider.markAllAsRead();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(lang.semuaNotifikasiDibaca),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            lang.tandaiSemua,
                            style: const TextStyle(
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (belumDibaca.isNotEmpty) ...[
                        Text(
                          lang.belumDibaca,
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
                          lang: lang,
                          onDetailTap: () => _showDetailNotifikasi(context, notif),
                        )),
                        const SizedBox(height: 16),
                      ],
                      if (sudahDibaca.isNotEmpty) ...[
                        Text(
                          lang.sudahDibaca,
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
                          lang: lang,
                          onDetailTap: () => _showDetailNotifikasi(context, notif),
                        )),
                      ],
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

  Widget _buildEmptyProfileState(AppLocalizations lang) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              lang.belumAdaProfil,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3A5C)),
            ),
            const SizedBox(height: 8),
            Text(
              lang.isiProfilDulu,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B3A5C),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                lang.kembali,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations lang) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              lang.tidakAdaNotifikasi,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B3A5C)),
            ),
            const SizedBox(height: 8),
            Text(
              lang.belumAdaNotifikasi,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B3A5C),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                lang.kembali,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifikasiCard(
      Map<String, dynamic> notif, {
        required bool isRead,
        required AppLocalizations lang,
        VoidCallback? onDetailTap,
      }) {
    String title = notif['title'] as String;
    Color statusColor;
    Color bgColor;
    String statusLabel;

    if (title.contains('Kritis') || title.contains('kritis')) {
      statusColor = const Color(0xFFEF4444);
      bgColor = const Color(0xFFFFF5F5);
      statusLabel = lang.kritis;
    } else if (title.contains('Tinggi') || title.contains('tinggi') || title.contains('Warning')) {
      statusColor = const Color(0xFFF59E0B);
      bgColor = const Color(0xFFFFFBEB);
      statusLabel = lang.warning;
    } else {
      statusColor = const Color(0xFF4FC3F7);
      bgColor = const Color(0xFFEFF8FF);
      statusLabel = lang.informasi;
    }

    return GestureDetector(
      onTap: onDetailTap,
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
            Container(
              margin: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.notifications_active,
                color: statusColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B3A5C),
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor.withOpacity(0.2)),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                    ],
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