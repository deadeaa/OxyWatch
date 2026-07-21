// screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDoctor = auth.currentUser?.role == UserRole.doctor;

    // Dashboard dokter sudah punya jalur sendiri buat mulai chat (tombol
    // chat di kartu pasien -> doctor_dashboard_screen.dart), jadi kalau
    // yang buka ini kebetulan dokter, cukup tampilkan riwayat chat yang
    // sudah ada saja (tidak perlu browse "semua parent" di sini juga).
    if (isDoctor) {
      return const _ExistingConversationsList();
    }

    // Sisi PARENT: tampilkan semua dokter yang bisa dihubungi, bukan cuma
    // riwayat chat yang sudah ada.
    return const _DoctorBrowseList();
  }
}

// ==========================
// SISI PARENT: browse semua dokter + prioritas urutan
// ==========================
class _DoctorBrowseList extends StatelessWidget {
  const _DoctorBrowseList();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final myUid = auth.currentUser?.uid ?? '';
    final chatService = ChatService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: const Color(0xFF1B3A5C),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Outer stream: daftar dokter (jarang berubah -> ditaruh di luar).
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .snapshots(),
        builder: (context, doctorSnap) {
          if (doctorSnap.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${doctorSnap.error}'));
          }
          if (!doctorSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final doctorDocs = doctorSnap.data!.docs;
          if (doctorDocs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada dokter yang terdaftar.',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            );
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            // Inner stream: percakapan aku (buat tahu siapa yang pernah
            // dihubungi + kapan terakhir chat + unread count).
            stream: chatService.streamMyConversations(),
            builder: (context, convoSnap) {
              // Map: doctorId -> data conversation (kalau ada)
              final Map<String, Map<String, dynamic>> conversationByDoctor = {};
              if (convoSnap.hasData) {
                for (final doc in convoSnap.data!.docs) {
                  final data = doc.data();
                  final doctorId = data['doctorId'] as String?;
                  if (doctorId != null) {
                    conversationByDoctor[doctorId] = {
                      'conversationId': doc.id,
                      ...data,
                    };
                  }
                }
              }

              // Gabungkan data dokter + data percakapan (kalau ada), lalu
              // hitung skor prioritas buat sorting.
              final entries = doctorDocs.map((doc) {
                final data = doc.data();
                final conversation = conversationByDoctor[doc.id];
                final isOnline = data['isOnline'] == true;
                final hasConversation = conversation != null;

                // Skor: 3 = pernah dihubungi + online (paling atas)
                //       2 = pernah dihubungi + offline
                //       1 = belum pernah dihubungi + online
                //       0 = belum pernah dihubungi + offline (paling bawah)
                final score = (hasConversation ? 2 : 0) + (isOnline ? 1 : 0);

                DateTime? lastMessageAt;
                final rawTimestamp = conversation?['lastMessageAt'];
                if (rawTimestamp is Timestamp) {
                  lastMessageAt = rawTimestamp.toDate();
                }

                return _DoctorEntry(
                  doctorId: doc.id,
                  fullName: data['fullName'] ?? 'Dokter',
                  isOnline: isOnline,
                  hasConversation: hasConversation,
                  conversationId: conversation?['conversationId'],
                  lastMessage: conversation?['lastMessage'] ?? '',
                  lastMessageAt: lastMessageAt,
                  unreadCount: (conversation?['unreadCount']?[myUid]) ?? 0,
                  score: score,
                );
              }).toList();

              entries.sort((a, b) {
                if (a.score != b.score) return b.score.compareTo(a.score);
                // Sesama skor: yang pernah chat diurut dari paling baru;
                // yang belum pernah chat diurut abjad nama.
                if (a.hasConversation && b.hasConversation) {
                  final atA = a.lastMessageAt ?? DateTime(2000);
                  final atB = b.lastMessageAt ?? DateTime(2000);
                  return atB.compareTo(atA);
                }
                return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
              });

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return _buildDoctorTile(context, entry, myUid, chatService);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDoctorTile(
      BuildContext context,
      _DoctorEntry entry,
      String myUid,
      ChatService chatService,
      ) {
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          try {
            final conversationId = await chatService.getOrCreateConversationId(
              doctorId: entry.doctorId,
              parentId: myUid,
            );
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(
                  conversationId: conversationId,
                  otherPersonName: entry.fullName,
                  otherPersonSubtitle: entry.isOnline ? 'Online' : 'Offline',
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
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF1B3A5C).withValues(alpha: 0.1),
                  child: Text(
                    entry.fullName.isNotEmpty ? entry.fullName[0] : '?',
                    style: const TextStyle(color: Color(0xFF1B3A5C), fontWeight: FontWeight.bold),
                  ),
                ),
                if (entry.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    entry.hasConversation
                        ? (entry.lastMessage.isEmpty ? 'Belum ada pesan' : entry.lastMessage)
                        : 'Ketuk untuk mulai chat',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (entry.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text(
                  '${entry.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DoctorEntry {
  final String doctorId;
  final String fullName;
  final bool isOnline;
  final bool hasConversation;
  final String? conversationId;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final int score;

  _DoctorEntry({
    required this.doctorId,
    required this.fullName,
    required this.isOnline,
    required this.hasConversation,
    required this.conversationId,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.score,
  });
}

// ==========================
// SISI DOKTER (fallback): riwayat chat yang sudah ada saja.
// Dokter mulai chat baru lewat tombol chat di kartu pasien
// (doctor_dashboard_screen.dart), bukan dari sini.
// ==========================
class _ExistingConversationsList extends StatelessWidget {
  const _ExistingConversationsList();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final myUid = auth.currentUser?.uid ?? '';
    final chatService = ChatService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: const Color(0xFF1B3A5C),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: chatService.streamMyConversations(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = snapshot.data!.docs;
          if (conversations.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada percakapan.\nMulai chat dari halaman daftar pasien.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final doc = conversations[index];
              final data = doc.data();
              final parentId = data['parentId'];
              final lastMessage = data['lastMessage'] ?? '';
              final unreadMap = Map<String, dynamic>.from(data['unreadCount'] ?? {});
              final myUnread = unreadMap[myUid] ?? 0;

              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance.collection('users').doc(parentId).get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) return const SizedBox.shrink();
                  final otherData = userSnap.data!.data() ?? {};
                  final anakNama = otherData['nama'] ?? 'Pasien';
                  final orangTuaNama = otherData['fullName'] ?? '-';

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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(
                              conversationId: doc.id,
                              otherPersonName: anakNama.toString(),
                              otherPersonSubtitle: 'Orang tua: $orangTuaNama',
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF1B3A5C).withValues(alpha: 0.1),
                            child: Text(
                              anakNama.toString().isNotEmpty ? anakNama.toString()[0] : '?',
                              style: const TextStyle(color: Color(0xFF1B3A5C), fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(anakNama.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  lastMessage.toString().isEmpty ? 'Belum ada pesan' : lastMessage.toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (myUnread > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: Text(
                                '$myUnread',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}