// screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dokter_model.dart';
import '../providers/auth_provider.dart';
import '../screens/chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Dokter> _dokterList = [];
  int _chatUnread = 2;

  @override
  void initState() {
    super.initState();
    _loadDokter();
  }

  void _loadDokter() {
    _dokterList = [
      Dokter(
        id: '1',
        nama: 'Dr. Siti Rahayu, Sp.A',
        spesialis: 'Spesialis Anak',
        foto: 'SR',
        online: true,
        lastActive: 'Online sekarang',
        rating: 4.9,
        totalPasien: 124,
        rumahSakit: 'RSAB Harapan Kita',
      ),
      Dokter(
        id: '2',
        nama: 'Dr. Andi Wijaya, Sp.A',
        spesialis: 'Spesialis Anak',
        foto: 'AW',
        online: true,
        lastActive: 'Online sekarang',
        rating: 4.8,
        totalPasien: 98,
        rumahSakit: 'RSIA Hermina',
      ),
      Dokter(
        id: '3',
        nama: 'Dr. Maria Susanti, Sp.A',
        spesialis: 'Spesialis Anak - Konsultan',
        foto: 'MS',
        online: false,
        lastActive: 'Terakhir online 2 jam lalu',
        rating: 4.9,
        totalPasien: 156,
        rumahSakit: 'RSUP Dr. Cipto',
      ),
      Dokter(
        id: '4',
        nama: 'Dr. Budi Santoso, Sp.A',
        spesialis: 'Spesialis Anak',
        foto: 'BS',
        online: false,
        lastActive: 'Terakhir online 5 jam lalu',
        rating: 4.7,
        totalPasien: 87,
        rumahSakit: 'RSIA Bunda',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final onlineDokter = _dokterList.where((d) => d.online).toList();
    final isProfileEmpty = auth.nama.isEmpty && auth.usia.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Chat dengan Dokter'),
        backgroundColor: const Color(0xFF1B3A5C),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: isProfileEmpty
          ? _buildEmptyState()
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CHAT DENGAN DOKTER',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            // Card chat utama
            _buildChatCard(auth),
            const SizedBox(height: 12),
            // Status semua chat terbaca
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF8FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.125)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4FC3F7),
                    size: 13,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Semua chat lain sudah terbaca',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF2E5A8A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Daftar dokter online lainnya
            if (onlineDokter.length > 1) ...[
              const Text(
                'DOKTER ONLINE LAINNYA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              ...onlineDokter
                  .where((d) => d.id != '1')
                  .map((dokter) => _buildDoctorChip(dokter)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada profil anak',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Isi profil anak terlebih dahulu untuk chat dengan dokter',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(AuthProvider auth) {
    final dokter = _dokterList[0]; // Dr. Siti Rahayu

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(dokter: dokter),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF0E1E3C).withOpacity(0.07)),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E5A8A),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.medical_services,
                      color: Color(0xFF4FC3F7),
                      size: 18,
                    ),
                  ),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$_chatUnread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dokter.nama,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B3A5C),
                    ),
                  ),
                  Text(
                    '${auth.nama.isNotEmpty ? auth.nama : 'Budi Santoso'} · ${auth.patientId.isNotEmpty ? auth.patientId : 'PED-0000'}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Selamat pagi. Bagaimana kondisi Budi setelah inhalasi?',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            // Time & chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '09:12',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right,
                  color: Color(0xFF94A3B8),
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorChip(Dokter dokter) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(dokter: dokter),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0E1E3C).withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF2E5A8A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  dokter.foto,
                  style: const TextStyle(
                    color: Color(0xFF4FC3F7),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dokter.nama,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B3A5C),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF94A3B8),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}