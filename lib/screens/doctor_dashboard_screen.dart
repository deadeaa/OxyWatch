import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifikasi_provider.dart';
import '../../services/chat_service.dart';
import 'login_screen.dart';
import 'notifikasi_screen.dart';
import 'chat_detail_screen.dart';
import 'chat_list_screen.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final TextEditingController _searchController = TextEditingController();
  final ChatService _chatService = ChatService();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
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

    // Pakai AuthProvider (bukan AuthService langsung) supaya state
    // isLoggedIn/currentUser ikut ter-reset, konsisten dengan dashboard parent.
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  // ==========================
  // HELPER: status dari nilai vital
  // ASUMSI: threshold ini masih placeholder, HARUS direview oleh
  // tenaga medis / dokter pembimbing sebelum dipakai untuk keputusan klinis.
  // ==========================
  ({String label, Color color}) _statusFromVitals(dynamic spo2, dynamic hr) {
    final spo2Val = spo2 is num ? spo2.toDouble() : double.tryParse('$spo2');
    final hrVal = hr is num ? hr.toDouble() : double.tryParse('$hr');

    if (spo2Val == null || hrVal == null) {
      return (label: 'Belum ada data', color: Colors.grey);
    }
    if (spo2Val < 92 || hrVal > 160 || hrVal < 60) {
      return (label: 'Perlu Perhatian Segera', color: const Color(0xFFEF4444));
    }
    if (spo2Val < 95 || hrVal > 140) {
      return (label: 'Perhatian', color: const Color(0xFFF59E0B));
    }
    return (label: 'Normal', color: const Color(0xFF22C55E));
  }

  // ==========================
  // HELPER: skor keparahan untuk sorting.
  // Makin tinggi angka, makin urgent -> ditaruh di atas list.
  // ==========================
  int _severityScore(dynamic spo2, dynamic hr) {
    final status = _statusFromVitals(spo2, hr);
    switch (status.label) {
      case 'Perlu Perhatian Segera':
        return 2;
      case 'Perhatian':
        return 1;
      case 'Normal':
        return 0;
      default: // 'Belum ada data'
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dokterNama = auth.currentUser?.fullName ?? 'Dokter'; // ASUMSI: field fullName ada di UserModel
    final initials = dokterNama.trim().isNotEmpty
        ? dokterNama.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'DR';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // ==========================
            // HEADER (biru tua, sesuai Figma)
            // ==========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1B3A5C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white24,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
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
                              dokterNama,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // ASUMSI: field spesialisasi belum tentu ada di UserModel.
                            // Ganti 'Dokter Anak · SpA' dengan data asli kalau sudah tersedia.
                            const Text(
                              'Dokter Anak · SpA',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer<NotifikasiProvider>(
                        builder: (context, notifProvider, _) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
                                  );
                                },
                              ),
                              if (notifProvider.belumDibaca > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                    child: Text(
                                      '${notifProvider.belumDibaca}',
                                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      // 🔥 BARU: pintu masuk ke daftar chat dokter (sebelumnya
                      // dokter tidak punya cara lihat "semua chat aku", cuma
                      // bisa buka chat spesifik lewat kartu pasien satu-satu).
                      StreamBuilder<int>(
                        stream: _chatService.streamTotalUnreadCount(),
                        builder: (context, snapshot) {
                          final unread = snapshot.data ?? 0;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                                tooltip: "Chat",
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ChatListScreen()),
                                  );
                                },
                              ),
                              if (unread > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                    child: Text(
                                      unread > 9 ? '9+' : '$unread',
                                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () => _handleLogout(context),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: "Logout",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Cari pasien...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================
            // BODY - daftar pasien real-time dari Firestore
            // ==========================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // FIX: role yang valid di UserModel cuma 'parent' dan 'doctor'
                // (lihat enum UserRole). Data "pasien" (anak) tersimpan sebagai
                // field profil (nama, usia, patientId, dst) di DALAM dokumen
                // akun parent, bukan sebagai role terpisah.
                //
                // ASUMSI KRITIS YANG MASIH BERLAKU: query ini mengambil SEMUA
                // user dengan role 'parent' yang profilnya sudah lengkap.
                // Ini KEMUNGKINAN BESAR salah dari sisi keamanan/privasi data:
                // seorang dokter seharusnya hanya melihat pasien yang di-assign
                // ke dia, bukan seluruh pasien di sistem. Lihat catatan review
                // di akhir chat untuk detail rekomendasi.
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'parent')
                    .where('profileCompleted', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nama = (data['nama'] ?? '').toString();
                    // Sembunyikan profil yang di-skip saat onboarding (nama
                    // kosong tapi profileCompleted tetap true) - ini bukan
                    // "pasien" yang berarti buat ditampilkan ke dokter.
                    if (nama.trim().isEmpty) return false;

                    final patientId = (data['patientId'] ?? '').toString().toLowerCase();
                    if (_searchQuery.isEmpty) return true;
                    return nama.toLowerCase().contains(_searchQuery) || patientId.contains(_searchQuery);
                  }).toList()
                    ..sort((a, b) {
                      final dataA = a.data() as Map<String, dynamic>;
                      final dataB = b.data() as Map<String, dynamic>;
                      final scoreA = _severityScore(dataA['spo2'], dataA['heartRate']);
                      final scoreB = _severityScore(dataB['spo2'], dataB['heartRate']);
                      return scoreB.compareTo(scoreA); // descending: paling parah di atas
                    });

                  if (docs.isEmpty) {
                    return const Center(child: Text('Belum ada pasien.'));
                  }

                  final urgentDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = _statusFromVitals(data['spo2'], data['heartRate']);
                    return status.label == 'Perlu Perhatian Segera';
                  }).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (urgentDocs.isNotEmpty) ...[
                          const Text(
                            'PERLU PERHATIAN SEGERA',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...urgentDocs.map((doc) => _buildUrgentCard(context, doc)),
                          const SizedBox(height: 20),
                        ],
                        Text(
                          'SEMUA PASIEN (${docs.length})',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...docs.map((doc) => _buildPatientCard(context, doc)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nama = data['nama'] ?? '-';
    final usia = data['usia'] ?? '-';
    final patientId = data['patientId'] ?? '-';
    final spo2 = data['spo2'] ?? '-';
    final hr = data['heartRate'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFD9D9),
            child: Text(
              nama.toString().isNotEmpty ? nama.toString()[0] : '?',
              style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$usia thn · $patientId', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Text(
                  'SpO2: $spo2%  HR: $hr bpm',
                  style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
          ),
          _chatButton(context, doc),
        ],
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nama = data['nama'] ?? '-';
    final usia = data['usia'] ?? '-';
    final patientId = data['patientId'] ?? '-';
    final spo2 = data['spo2'] ?? '-';
    final hr = data['heartRate'] ?? '-';
    final status = _statusFromVitals(data['spo2'], data['heartRate']);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1B3A5C).withValues(alpha: 0.1),
            child: Text(
              nama.toString().isNotEmpty ? nama.toString()[0] : '?',
              style: const TextStyle(color: Color(0xFF1B3A5C), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$usia thn · $patientId', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Text('SpO2: $spo2%  HR: $hr bpm', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: status.color.withValues(alpha: 0.3)),
            ),
            child: Text(
              status.label,
              style: TextStyle(color: status.color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          _chatButton(context, doc),
        ],
      ),
    );
  }

  Widget _chatButton(BuildContext context, QueryDocumentSnapshot doc) {
    return IconButton(
      icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF1B3A5C)),
      onPressed: () async {
        final auth = context.read<AuthProvider>();
        final myUid = auth.currentUser?.uid;
        if (myUid == null) return;

        final data = doc.data() as Map<String, dynamic>;
        final anakNama = data['nama'] ?? 'Pasien';
        final orangTuaNama = data['fullName'] ?? '-';

        try {
          final conversationId = await _chatService.getOrCreateConversationId(
            doctorId: myUid,
            parentId: doc.id,
          );

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                conversationId: conversationId,
                otherPersonName: anakNama.toString(),
                otherPersonSubtitle: 'Orang tua: $orangTuaNama',
              ),
            ),
          );
        } catch (e) {
          // 🔥 FIX: sebelumnya kalau ini gagal (misal permission-denied
          // dari Firestore rules), error-nya ditelan diam-diam - tombol
          // kelihatan seperti tidak melakukan apapun. Sekarang minimal
          // ada feedback yang kelihatan, supaya gampang di-debug.
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal membuka chat: $e')),
            );
          }
        }
      },
    );
  }
}