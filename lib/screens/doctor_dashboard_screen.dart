// screens/doctor/doctor_dashboard_screen.dart - FULL CODE YANG DIPERBAIKI

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifikasi_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/chat_service.dart';
import '../../models/chat_message_model.dart';
import '../../models/user_model.dart';
import 'login_screen.dart';
import 'notifikasi_screen.dart';
import 'chat_detail_screen.dart';
import 'chat_list_screen.dart';
import 'role_selection_screen.dart';
import '../../utils/languages.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final TextEditingController _searchController = TextEditingController();
  final ChatService _chatService = ChatService();
  String _searchQuery = '';

  // Tab view
  String _currentView = 'patients';
  String? _selectedPatientId;

  // Untuk total unread chat
  int _totalUnreadChats = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  void _loadUnreadCount() {
    _chatService.streamTotalUnreadCount().listen((count) {
      if (mounted) {
        setState(() {
          _totalUnreadChats = count;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final lang = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.logout),
        content: Text(lang.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              lang.logout,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
          (route) => false,
    );
  }

  // ==========================
  // HELPER: status dari nilai vital
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

  int _severityScore(dynamic spo2, dynamic hr) {
    final status = _statusFromVitals(spo2, hr);
    switch (status.label) {
      case 'Perlu Perhatian Segera':
        return 2;
      case 'Perhatian':
        return 1;
      case 'Normal':
        return 0;
      default:
        return -1;
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  // ==========================
  // 🔥 HELPER AMAN untuk ambil unreadCount dari Map
  // ==========================
  int _getUnreadCountSafe(Map<String, dynamic>? data, String myUid) {
    if (data == null) return 0;

    // Coba ambil unreadCount
    final unreadCount = data['unreadCount'];
    if (unreadCount == null) return 0;

    // Jika unreadCount adalah Map (per user)
    if (unreadCount is Map) {
      // Coba ambil untuk user ini
      final value = unreadCount[myUid];
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      // Jika tidak ada untuk user ini, coba jumlahkan semua
      int total = 0;
      for (final v in unreadCount.values) {
        if (v is int) total += v;
        else if (v is String) total += int.tryParse(v) ?? 0;
        else if (v is num) total += v.toInt();
      }
      return total;
    }

    // Jika unreadCount adalah angka langsung
    if (unreadCount is int) return unreadCount;
    if (unreadCount is String) return int.tryParse(unreadCount) ?? 0;
    if (unreadCount is num) return unreadCount.toInt();

    return 0;
  }

  // ==========================
  // HELPER AMAN untuk ambil lastMessage
  // ==========================
  String _getLastMessageSafe(Map<String, dynamic>? data) {
    if (data == null) return '';
    final message = data['lastMessage'];
    if (message == null) return '';
    return message.toString();
  }

  // ==========================
  // HELPER AMAN untuk ambil lastMessageTime
  // ==========================
  DateTime? _getLastMessageTimeSafe(Map<String, dynamic>? data) {
    if (data == null) return null;
    final time = data['lastMessageAt'];
    if (time == null) return null;
    if (time is Timestamp) return time.toDate();
    if (time is DateTime) return time;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = AppLocalizations.of(context)!;
    final dokterNama = auth.currentUser?.fullName ?? 'Dokter';
    final initials = _getInitials(dokterNama);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, lang, dokterNama, initials),
            Expanded(
              child: _currentView == 'chat'
                  ? _buildChatView(context, lang)
                  : _currentView == 'dashboard'
                  ? _buildDashboardView(context, lang)
                  : _currentView == 'profile'
                  ? _buildProfileView(context, lang)
                  : _currentView == 'notifications'
                  ? _buildNotificationsView(context, lang)
                  : _buildPatientsView(context, lang),
            ),
            _buildBottomNav(context, lang),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations lang, String name, String initials) {
    return Container(
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
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      lang.pediatrician,
                      style: const TextStyle(
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
                          setState(() => _currentView = 'notifications');
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
              IconButton(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: "Logout",
              ),
            ],
          ),
          if (_currentView == 'patients') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: lang.searchPatient,
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
        ],
      ),
    );
  }

  // ==========================
  // PATIENTS VIEW
  // ==========================
  Widget _buildPatientsView(BuildContext context, AppLocalizations lang) {
    final auth = context.watch<AuthProvider>();
    final myUid = auth.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'parent')
          .where('profileCompleted', isEqualTo: true)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${userSnapshot.error}'));
        }
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = userSnapshot.data!.docs;

        if (allDocs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Belum ada pasien yang terdaftar.',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('conversations')
              .where('participants', arrayContains: myUid)
              .snapshots(),
          builder: (context, convoSnapshot) {
            final Map<String, Map<String, dynamic>> conversationMap = {};
            if (convoSnapshot.hasData) {
              for (final doc in convoSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final parentId = data['parentId'] as String?;
                if (parentId != null) {
                  // 🔥 Gunakan helper aman
                  final unreadCount = _getUnreadCountSafe(data, myUid);

                  conversationMap[parentId] = {
                    'conversationId': doc.id,
                    'unreadCount': unreadCount,
                    'lastMessage': _getLastMessageSafe(data),
                    'lastMessageAt': data['lastMessageAt'],
                    ...data,
                  };
                }
              }
            }

            final docs = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final nama = (data['nama'] ?? '').toString();
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
                return scoreB.compareTo(scoreA);
              });

            if (docs.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Tidak ada pasien yang cocok dengan pencarian.',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
              );
            }

            final urgentDocs = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final status = _statusFromVitals(data['spo2'], data['heartRate']);
              return status.label == 'Perlu Perhatian Segera';
            }).toList();

            final restDocs = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final status = _statusFromVitals(data['spo2'], data['heartRate']);
              return status.label != 'Perlu Perhatian Segera';
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (urgentDocs.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: const Color(0xFFF59E0B), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          lang.needImmediateAttention,
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...urgentDocs.map((doc) => _buildPatientCard(
                        context,
                        doc,
                        conversationMap[doc.id],
                        isCritical: true
                    )),
                    const SizedBox(height: 20),
                  ],

                  Row(
                    children: [
                      Text(
                        lang.allPatients,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B3A5C),
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Text(
                          '${docs.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...restDocs.map((doc) => _buildPatientCard(
                      context,
                      doc,
                      conversationMap[doc.id],
                      isCritical: false
                  )),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPatientCard(
      BuildContext context,
      QueryDocumentSnapshot doc,
      Map<String, dynamic>? conversation,
      {required bool isCritical}
      ) {
    final data = doc.data() as Map<String, dynamic>;
    final nama = data['nama'] ?? '-';
    final usia = data['usia'] ?? '-';
    final patientId = data['patientId'] ?? '-';
    final spo2 = data['spo2'] ?? '-';
    final hr = data['heartRate'] ?? '-';
    final status = _statusFromVitals(data['spo2'], data['heartRate']);
    final initials = _getInitials(nama.toString());

    // 🔥 Ambil dari conversation dengan aman - PERBAIKI CAST
    int unreadCount = 0;
    String lastMessage = '';
    if (conversation != null) {
      // Gunakan helper aman
      final rawUnread = conversation['unreadCount'];
      if (rawUnread is int) {
        unreadCount = rawUnread;
      } else if (rawUnread is String) {
        unreadCount = int.tryParse(rawUnread) ?? 0;
      } else if (rawUnread is num) {
        unreadCount = rawUnread.toInt();
      } else {
        unreadCount = 0;
      }
      lastMessage = conversation['lastMessage'] ?? '';
    }
    final hasMessage = lastMessage.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: isCritical
            ? Border.all(color: const Color(0xFFEF4444), width: 1.5)
            : Border.all(color: Colors.transparent),
        boxShadow: isCritical ? null : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCritical ? const Color(0xFFFFD9D9) : const Color(0xFF1B3A5C).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: isCritical ? const Color(0xFFEF4444) : const Color(0xFF1B3A5C),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '$usia thn · $patientId',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
                Row(
                  children: [
                    Text(
                      'SpO₂: $spo2%  HR: $hr bpm',
                      style: TextStyle(
                        color: isCritical ? const Color(0xFFEF4444) : Colors.grey.shade700,
                        fontWeight: isCritical ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (hasMessage) ...[
                  const SizedBox(height: 2),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unreadCount > 0 ? const Color(0xFF1B3A5C) : Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  border: Border.all(color: status.color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(color: status.color, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 4),
              _buildChatButton(context, doc.id, unreadCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton(BuildContext context, String parentId, int unreadCount) {
    return GestureDetector(
      onTap: () async {
        final auth = context.read<AuthProvider>();
        final myUid = auth.currentUser?.uid;
        if (myUid == null) return;

        try {
          final conversationId = await _chatService.getOrCreateConversationId(
            doctorId: myUid,
            parentId: parentId,
          );

          if (!context.mounted) return;

          await _chatService.markConversationAsRead(conversationId);

          setState(() {});

          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(parentId)
              .get();
          final userData = userDoc.data() as Map<String, dynamic>? ?? {};

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                conversationId: conversationId,
                otherPersonName: userData['nama'] ?? 'Pasien',
                otherPersonSubtitle: 'Orang tua: ${userData['fullName'] ?? '-'}',
                onBack: () {
                  setState(() {});
                },
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
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF8FF),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFF1B3A5C),
              size: 16,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
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
      ),
    );
  }

  // ==========================
  // CHAT VIEW
  // ==========================
  Widget _buildChatView(BuildContext context, AppLocalizations lang) {
    final auth = context.watch<AuthProvider>();
    final myUid = auth.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .where('participants', arrayContains: myUid)
          .orderBy('lastMessageAt', descending: true)
          .snapshots(),
      builder: (context, convoSnapshot) {
        if (convoSnapshot.hasError) {
          return Center(child: Text('Terjadi kesalahan: ${convoSnapshot.error}'));
        }
        if (!convoSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final conversations = convoSnapshot.data!.docs;

        if (conversations.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Belum ada percakapan.',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ),
          );
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _buildChatItems(conversations, myUid),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snapshot.data!;

            final unreadItems = <Map<String, dynamic>>[];
            final readItems = <Map<String, dynamic>>[];

            for (final item in items) {
              final unreadCount = (item['unreadCount'] as int?) ?? 0;
              if (unreadCount > 0) {
                unreadItems.add(item);
              } else {
                readItems.add(item);
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (unreadItems.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          lang.unreadChats,
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Text(
                            '${unreadItems.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...unreadItems.map((item) => _buildChatItemWidget(
                        context,
                        item,
                        isUnread: true
                    )),
                    const SizedBox(height: 20),
                  ],

                  if (readItems.isNotEmpty) ...[
                    Text(
                      lang.readChats,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...readItems.map((item) => _buildChatItemWidget(
                        context,
                        item,
                        isUnread: false
                    )),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _buildChatItems(
      List<QueryDocumentSnapshot> conversations,
      String myUid,
      ) async {
    final List<Map<String, dynamic>> items = [];

    for (final doc in conversations) {
      final data = doc.data() as Map<String, dynamic>;
      final parentId = data['parentId'] as String?;
      if (parentId == null) continue;

      // 🔥 Gunakan helper aman
      final unreadCount = _getUnreadCountSafe(data, myUid);

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(parentId)
            .get();

        final userData = userDoc.data() as Map<String, dynamic>? ?? {};
        final nama = userData['nama'] ?? 'Pasien';
        final patientId = userData['patientId'] ?? '-';
        final lastMessage = _getLastMessageSafe(data);
        final lastMessageAt = data['lastMessageAt'];

        items.add({
          'conversationId': doc.id,
          'parentId': parentId,
          'nama': nama,
          'patientId': patientId,
          'lastMessage': lastMessage,
          'lastMessageAt': lastMessageAt,
          'unreadCount': unreadCount,
        });
      } catch (e) {
        continue;
      }
    }

    items.sort((a, b) {
      final atA = a['lastMessageAt'] as Timestamp?;
      final atB = b['lastMessageAt'] as Timestamp?;
      if (atA == null && atB == null) return 0;
      if (atA == null) return 1;
      if (atB == null) return -1;
      return atB.toDate().compareTo(atA.toDate());
    });

    return items;
  }

  Widget _buildChatItemWidget(
      BuildContext context,
      Map<String, dynamic> item,
      {required bool isUnread}
      ) {
    final nama = item['nama'] ?? 'Pasien';
    final patientId = item['patientId'] ?? '-';
    final unreadCount = (item['unreadCount'] as int?) ?? 0;
    final lastMessage = item['lastMessage'] ?? '';
    final hasMessage = lastMessage.isNotEmpty;
    final initials = _getInitials(nama.toString());

    String timeString = '';
    final lastMessageAt = item['lastMessageAt'];
    if (lastMessageAt != null) {
      try {
        final date = (lastMessageAt as Timestamp).toDate();
        timeString = DateFormat('HH:mm').format(date);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: isUnread ? Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3), width: 1.5) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xFFFFD9D9) : const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: isUnread ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: Text(
          nama,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
            color: const Color(0xFF1B3A5C),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$patientId',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
            ),
            Text(
              hasMessage ? lastMessage : 'Belum ada pesan',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isUnread ? const Color(0xFF1B3A5C) : Colors.grey.shade400,
                fontSize: 11,
                fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (timeString.isNotEmpty)
              Text(
                timeString,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 9),
              ),
            const SizedBox(height: 4),
            if (isUnread && unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (!isUnread && hasMessage)
              const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 16),
            if (!isUnread && !hasMessage)
              const Icon(Icons.check_circle, color: Color(0xFF94A3B8), size: 16),
          ],
        ),
        onTap: () async {
          final conversationId = item['conversationId'] as String;
          await _chatService.markConversationAsRead(conversationId);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                conversationId: conversationId,
                otherPersonName: nama.toString(),
                otherPersonSubtitle: 'Orang tua: ${item['parentId']}',
                onBack: () {
                  setState(() {});
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================
  // DASHBOARD VIEW
  // ==========================
  Widget _buildDashboardView(BuildContext context, AppLocalizations lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A1628), Color(0xFF1E3A5F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.globalHealthUpdate,
                  style: const TextStyle(
                    color: Color(0xFF4FC3F7),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'WHO: Infeksi Saluran Napas Anak Meningkat 12% di Asia Tenggara',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pantau pasien dengan riwayat asma dan prematur lebih intensif.',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '5 Juli 2026 · WHO Report',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: lang.avgSpO2,
                  value: '95.5%',
                  color: const Color(0xFF4FC3F7),
                  bgColor: const Color(0xFFEFF8FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: lang.needAttention,
                  value: '2',
                  color: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFFF5F5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: lang.consultationsToday,
                  value: '6',
                  color: const Color(0xFF22C55E),
                  bgColor: const Color(0xFFF0FDF4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: lang.activeAlerts,
                  value: '4',
                  color: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFFFFBEB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.clinicalTips,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTipItem('SpO₂ < 94% → segera evaluasi oksigenasi'),
                _buildTipItem('HR > 140 bpm anak < 5thn → cek demam & distres'),
                _buildTipItem('Rekam baseline vital sebelum terapi inhalasi'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.seasonWarning,
                        style: const TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        lang.seasonWarningDesc,
                        style: const TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String label, required String value, required Color color, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF4FC3F7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 11, color: Color(0xFF1B3A5C)),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // PROFILE VIEW
  // ==========================
  Widget _buildProfileView(BuildContext context, AppLocalizations lang) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final languageProvider = context.watch<LanguageProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0A1628), Color(0xFF1E3A5F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(user?.fullName ?? 'DR'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Dokter',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        lang.pediatrician,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        user?.email ?? '-',
                        style: const TextStyle(
                          color: Color(0xFF4FC3F7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.licenseSIP,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                _buildProfileInfo(lang.licenseNumber, '1234/SIP/2024'),
                _buildProfileInfo(lang.institution, 'Press Healthcare'),
                _buildProfileInfo(lang.specialization, 'Pediatri (SpA)'),
                _buildProfileInfo(lang.validUntil, '31 Des 2026'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.settings,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.language,
                            style: const TextStyle(
                              color: Color(0xFF1B3A5C),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            lang.changeLanguage,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _buildLanguageButton('id', 'ID', languageProvider, context, auth),
                          _buildLanguageButton('en', 'EN', languageProvider, context, auth),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 20),
                _buildSettingsItem(
                  icon: Icons.notifications_active,
                  title: lang.patientAlerts,
                  subtitle: lang.alertNotifications,
                  onTap: () {},
                ),
                const Divider(color: Color(0xFFF1F5F9), height: 16),
                _buildSettingsItem(
                  icon: Icons.security,
                  title: lang.accountSecurity,
                  subtitle: lang.securitySettings,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _handleLogout(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
              ),
              child: Text(
                lang.logout,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(
      String code,
      String label,
      LanguageProvider lang,
      BuildContext context,
      AuthProvider auth,
      ) {
    final isSelected = lang.currentLanguage == code;
    return GestureDetector(
      onTap: () {
        lang.setLanguage(code);
        auth.updateUserLanguage(code);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.translate, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    code == 'id'
                        ? '🌏 Bahasa diubah ke Indonesia'
                        : '🌏 Language changed to English',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    code.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1B3A5C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B3A5C) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1B3A5C),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1B3A5C), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1B3A5C),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 16),
          ],
        ),
      ),
    );
  }

  // ==========================
  // NOTIFICATIONS VIEW
  // ==========================
  Widget _buildNotificationsView(BuildContext context, AppLocalizations lang) {
    return Consumer<NotifikasiProvider>(
      builder: (context, notifProvider, _) {
        final allNotif = notifProvider.getAllNotifikasi();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    lang.notifications,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B3A5C),
                    ),
                  ),
                  const Spacer(),
                  if (allNotif.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        notifProvider.markAllAsRead();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(lang.allNotificationsRead)),
                        );
                      },
                      child: Text(
                        lang.markAllRead,
                        style: const TextStyle(
                          color: Color(0xFF4FC3F7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (allNotif.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Icon(Icons.notifications_off, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        lang.noNotifications,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      ),
                    ],
                  ),
                )
              else
                ...allNotif.map((notif) {
                  final isRead = notif['read'] as bool? ?? false;
                  final isCritical = notif['type'] == 'critical';
                  final isWarning = notif['type'] == 'warning';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.white : const Color(0xFFFFF5F5),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      border: isRead
                          ? Border.all(color: const Color(0xFFE2E8F0))
                          : Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCritical ? Icons.warning_amber_rounded :
                          isWarning ? Icons.warning : Icons.info_outline,
                          color: isCritical ? const Color(0xFFEF4444) :
                          isWarning ? const Color(0xFFF59E0B) :
                          const Color(0xFF4FC3F7),
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif['title'] ?? '',
                                style: TextStyle(
                                  fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                  fontSize: 12,
                                  color: const Color(0xFF1B3A5C),
                                ),
                              ),
                              Text(
                                notif['body'] ?? '',
                                style: TextStyle(
                                  color: isRead ? Colors.grey.shade600 : const Color(0xFF1B3A5C),
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                notif['time'] ?? '',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  // ==========================
  // BOTTOM NAV
  // ==========================
  Widget _buildBottomNav(BuildContext context, AppLocalizations lang) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            label: lang.dashboard,
            isActive: _currentView == 'dashboard',
            onTap: () => setState(() => _currentView = 'dashboard'),
          ),
          _buildNavItem(
            icon: Icons.people_outline,
            label: lang.patients,
            isActive: _currentView == 'patients',
            onTap: () => setState(() => _currentView = 'patients'),
          ),
          _buildNavItem(
            icon: Icons.chat_bubble_outline,
            label: lang.chat,
            isActive: _currentView == 'chat',
            badge: _totalUnreadChats,
            onTap: () => setState(() => _currentView = 'chat'),
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            label: lang.profile,
            isActive: _currentView == 'profile',
            onTap: () => setState(() => _currentView = 'profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    int? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFF1B3A5C) : const Color(0xFF94A3B8),
                size: 22,
              ),
              if (badge != null && badge > 0)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      badge > 9 ? '9+' : '$badge',
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
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF1B3A5C) : const Color(0xFF94A3B8),
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF4FC3F7),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}