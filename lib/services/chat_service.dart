// lib/services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _myUid => FirebaseAuth.instance.currentUser?.uid;

  /// ID conversation dibuat deterministik dari gabungan uid dokter & parent,
  /// supaya kalau conversation-nya sudah ada, kita tidak bikin dokumen baru.
  String _buildConversationId(String doctorId, String parentId) {
    return '${doctorId}_$parentId';
  }

  /// Ambil conversationId antara dokter & parent tertentu.
  /// Kalau belum ada dokumen conversation-nya, otomatis dibuat.
  Future<String> getOrCreateConversationId({
    required String doctorId,
    required String parentId,
  }) async {
    final conversationId = _buildConversationId(doctorId, parentId);
    final ref = _firestore.collection('conversations').doc(conversationId);
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      await ref.set({
        'participants': [doctorId, parentId],
        'doctorId': doctorId,
        'parentId': parentId,
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCount': {doctorId: 0, parentId: 0},
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return conversationId;
  }

  /// Stream semua pesan di satu conversation, urut dari yang terlama.
  Stream<List<ChatMessage>> streamMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ChatMessage.fromDoc(doc.id, doc.data()))
        .toList());
  }

  /// Kirim pesan teks biasa.
  Future<void> sendMessage({
    required String conversationId,
    required String text,
    required String senderRole, // 'doctor' atau 'parent'
    bool isVitalSnapshot = false,
  }) async {
    final uid = _myUid;
    if (uid == null) throw Exception('User belum login.');
    if (text.trim().isEmpty) return;

    final conversationRef =
    _firestore.collection('conversations').doc(conversationId);

    await conversationRef.collection('messages').add({
      'senderId': uid,
      'senderRole': senderRole,
      'text': text.trim(),
      'sentAt': FieldValue.serverTimestamp(),
      'read': false,
      'isVitalSnapshot': isVitalSnapshot,
    });

    // Update ringkasan percakapan supaya chat_list_screen bisa nampilin
    // "pesan terakhir" tanpa harus buka semua messages subcollection.
    final conversationSnap = await conversationRef.get();
    final data = conversationSnap.data();
    if (data != null) {
      final participants = List<String>.from(data['participants'] ?? []);
      final otherUid = participants.firstWhere(
            (p) => p != uid,
        orElse: () => '',
      );
      final currentUnread =
      Map<String, dynamic>.from(data['unreadCount'] ?? {});
      if (otherUid.isNotEmpty) {
        currentUnread[otherUid] = (currentUnread[otherUid] ?? 0) + 1;
      }

      await conversationRef.update({
        'lastMessage': isVitalSnapshot ? '📊 Data vital dikirim' : text.trim(),
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCount': currentUnread,
      });
    }
  }

  /// Tandai semua pesan di conversation ini sebagai sudah dibaca oleh user
  /// yang sedang login, dan reset counter unread miliknya.
  Future<void> markConversationAsRead(String conversationId) async {
    final uid = _myUid;
    if (uid == null) return;

    final conversationRef =
    _firestore.collection('conversations').doc(conversationId);

    await conversationRef.update({
      'unreadCount.$uid': 0,
    });

    final unreadMessages = await conversationRef
        .collection('messages')
        .where('read', isEqualTo: false)
        .where('senderId', isNotEqualTo: uid)
        .get();

    for (final doc in unreadMessages.docs) {
      await doc.reference.update({'read': true});
    }
  }

  /// Stream daftar conversation milik user yang sedang login (dokter atau
  /// parent), diurutkan dari yang paling baru ada aktivitas.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyConversations() {
    final uid = _myUid;
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  /// Total pesan belum dibaca di SEMUA percakapan milik user yang sedang
  /// login. Dipakai buat badge angka merah di tab Chat / icon chat.
  Stream<int> streamTotalUnreadCount() {
    final uid = _myUid;
    if (uid == null) return Stream.value(0);

    return streamMyConversations().map((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        final unreadMap = Map<String, dynamic>.from(doc.data()['unreadCount'] ?? {});
        final myUnread = unreadMap[uid];
        if (myUnread is int) total += myUnread;
      }
      return total;
    });
  }
}