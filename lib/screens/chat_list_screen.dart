// screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  // searchQuery dipakai kalau screen ini dibuka sebagai tab dokter
  // (di dalam DoctorMainScreen, difilter dari search bar bersama).
  // Untuk sisi parent, biarkan default '' (tidak dipakai, punya Scaffold
  // & search sendiri).
  final String searchQuery;

  const ChatListScreen({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDoctor = auth.currentUser?.role == UserRole.doctor;

    if (isDoctor) {
      return _ExistingConversationsList(searchQuery: searchQuery);
    }

    return const _DoctorBrowseList();
  }
}

// ==========================
// SISI PARENT: browse semua dokter + prioritas urutan
// (masih punya Scaffold+AppBar sendiri, dipakai standalone lewat bottom
// nav MainScreen parent, bukan di bawah shared header)
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
                child: Text('Belum ada dokter yang terdaftar.', style: TextStyle(color: Color(0xFF94A3B8))),
              ),
            );
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: chatService.streamMyConversations(),
            builder: (context, convoSnap) {
              final Map<String, Map<String, dynamic>> conversationByDoctor = {};
              if (convoSnap.hasData) {
                for (final doc in convoSnap.data!.docs) {
                  final data = doc.data();
                  final doctorId = data['doctorId'] as String?;
                  if (doctorId != null) {
                    conversationByDoctor[doctorId] = {'conversationId': doc.id, ...data};
                  }
                }
              }

              final entries = doctorDocs.map((doc) {
                final data = doc.data();
                final conversation = conversationByDoctor[doc.id];
                final isOnline = data['isOnline'] == true;
                final hasConversation = conversation != null;
                final score = (hasConversation ? 2 : 0) + (isOnline ? 1 : 0);

                DateTime? lastMessageAt;
                final rawTimestamp = conversation?['lastMessageAt'];
                if (rawTimestamp is Timestamp) lastMessageAt = rawTimestamp.toDate();

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
                itemBuilder: (context, index) => _buildDoctorTile(context, entries[index], myUid, chatService),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDoctorTile(BuildContext context, _DoctorEntry entry, String myUid, ChatService chatService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          try {
            final conversationId = await chatService.getOrCreateConversationId(doctorId: entry.doctorId, parentId: myUid);
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuka chat: $e')));
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
                      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
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
                    entry.hasConversation ? (entry.lastMessage.isEmpty ? 'Belum ada pesan' : entry.lastMessage) : 'Ketuk untuk mulai chat',
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
                child: Text('${entry.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
// SISI DOKTER: riwayat chat, di-embed sebagai BODY (tanpa Scaffold/AppBar
// sendiri) karena header sudah disediakan DoctorMainScreen.
// Redesain sesuai Figma: judul bold = NAMA ORTU (bukan nama anak),
// subtitle = nama anak + PED-ID, dipisah grup "Belum Dibaca/Dibalas"
// (badge merah) vs "Sudah Dibaca" (centang hijau).
// ==========================
class _ExistingConversationsList extends StatelessWidget {
  final String searchQuery;
  const _ExistingConversationsList({this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final myUid = auth.currentUser?.uid ?? '';
    final chatService = ChatService();
    final query = searchQuery.toLowerCase();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                'Belum ada percakapan.\nMulai chat dari tab Pasien.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ),
          );
        }

        // Perlu data parent (nama ortu, nama anak) buat tiap conversation
        // sebelum bisa filter search & grouping - pakai FutureBuilder
        // gabungan (Future.wait) supaya list-nya utuh sekali render,
        // bukan flicker satu-satu kayak FutureBuilder per-item.
        return FutureBuilder<List<_ConversationEntry>>(
          future: _loadEntries(conversations, myUid),
          builder: (context, entriesSnap) {
            if (!entriesSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var entries = entriesSnap.data!;
            if (query.isNotEmpty) {
              entries = entries.where((e) {
                return e.parentName.toLowerCase().contains(query) ||
                    e.anakNama.toLowerCase().contains(query) ||
                    e.patientId.toLowerCase().contains(query);
              }).toList();
            }

            if (entries.isEmpty) {
              return const Center(child: Text('Tidak ada percakapan yang cocok.'));
            }

            final belumDibaca = entries.where((e) => e.unreadCount > 0).toList();
            final sudahDibaca = entries.where((e) => e.unreadCount == 0).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (belumDibaca.isNotEmpty) ...[
                  Row(
                    children: [
                      const Text(
                        'BELUM DIBACA / DIBALAS',
                        style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                        decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                        child: Text('${belumDibaca.length}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...belumDibaca.map((e) => _buildTile(context, e, unread: true)),
                  const SizedBox(height: 20),
                ],
                if (sudahDibaca.isNotEmpty) ...[
                  const Text('SUDAH DIBACA', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 12)),
                  const SizedBox(height: 8),
                  ...sudahDibaca.map((e) => _buildTile(context, e, unread: false)),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Future<List<_ConversationEntry>> _loadEntries(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> conversations,
      String myUid,
      ) async {
    final results = await Future.wait(conversations.map((doc) async {
      final data = doc.data();
      final parentId = data['parentId'] as String?;
      final userDoc = parentId != null
          ? await FirebaseFirestore.instance.collection('users').doc(parentId).get()
          : null;
      final userData = userDoc?.data() ?? {};
      final unreadMap = Map<String, dynamic>.from(data['unreadCount'] ?? {});

      return _ConversationEntry(
        conversationId: doc.id,
        parentName: userData['fullName'] ?? 'Orang Tua',
        anakNama: userData['nama'] ?? 'Pasien',
        patientId: userData['patientId'] ?? '-',
        lastMessage: data['lastMessage'] ?? '',
        unreadCount: (unreadMap[myUid] is int) ? unreadMap[myUid] : 0,
      );
    }));
    return results;
  }

  Widget _buildTile(BuildContext context, _ConversationEntry e, {required bool unread}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: unread
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                conversationId: e.conversationId,
                otherPersonName: e.anakNama,
                otherPersonSubtitle: 'Orang tua: ${e.parentName}',
              ),
            ),
          );
        },
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: unread ? const Color(0xFFFFD9D9) : const Color(0xFF1B3A5C).withValues(alpha: 0.1),
                  child: Text(
                    e.parentName.isNotEmpty ? e.parentName[0] : '?',
                    style: TextStyle(
                      color: unread ? const Color(0xFFEF4444) : const Color(0xFF1B3A5C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (unread)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.parentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${e.anakNama} · ${e.patientId}', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    e.lastMessage.isEmpty ? 'Belum ada pesan' : e.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text('${e.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              )
            else
              const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20),
          ],
        ),
      ),
    );
  }
}

class _ConversationEntry {
  final String conversationId;
  final String parentName;
  final String anakNama;
  final String patientId;
  final String lastMessage;
  final int unreadCount;

  _ConversationEntry({
    required this.conversationId,
    required this.parentName,
    required this.anakNama,
    required this.patientId,
    required this.lastMessage,
    required this.unreadCount,
  });
}