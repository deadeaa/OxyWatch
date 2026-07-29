// screens/doctor_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../utils/patient_status_utils.dart';
import 'chat_detail_screen.dart';

class DoctorDashboard extends StatelessWidget {
  final String searchQuery;

  const DoctorDashboard({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    final query = searchQuery.toLowerCase();
    final chatService = ChatService();

    return StreamBuilder<QuerySnapshot>(
      // ASUMSI KRITIS yang masih berlaku: query ini mengambil SEMUA parent
      // dengan profil lengkap, belum ada assignment dokter-pasien spesifik.
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
          // Sembunyikan profil yang di-skip saat onboarding (nama kosong).
          if (nama.trim().isEmpty) return false;

          final patientId = (data['patientId'] ?? '').toString().toLowerCase();
          if (query.isEmpty) return true;
          return nama.toLowerCase().contains(query) || patientId.contains(query);
        }).toList()
          ..sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final scoreA = severityScore(dataA['spo2'], dataA['heartRate']);
            final scoreB = severityScore(dataB['spo2'], dataB['heartRate']);
            return scoreB.compareTo(scoreA);
          });

        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Belum ada pasien.', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
          );
        }

        final urgentDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = statusFromVitals(data['spo2'], data['heartRate']);
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
                  style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                ...urgentDocs.map((doc) => _buildUrgentCard(context, doc, chatService)),
                const SizedBox(height: 20),
              ],
              Text(
                'SEMUA PASIEN (${docs.length})',
                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 12),
              ),
              const SizedBox(height: 8),
              ...docs.map((doc) => _buildPatientCard(context, doc, chatService)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUrgentCard(BuildContext context, QueryDocumentSnapshot doc, ChatService chatService) {
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
          _chatButton(context, doc, chatService),
        ],
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, QueryDocumentSnapshot doc, ChatService chatService) {
    final data = doc.data() as Map<String, dynamic>;
    final nama = data['nama'] ?? '-';
    final usia = data['usia'] ?? '-';
    final patientId = data['patientId'] ?? '-';
    final spo2 = data['spo2'] ?? '-';
    final hr = data['heartRate'] ?? '-';
    final status = statusFromVitals(data['spo2'], data['heartRate']);
    final statusColor = Color(status.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
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
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(status.label, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          _chatButton(context, doc, chatService),
        ],
      ),
    );
  }

  Widget _chatButton(BuildContext context, QueryDocumentSnapshot doc, ChatService chatService) {
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
          final conversationId = await chatService.getOrCreateConversationId(
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