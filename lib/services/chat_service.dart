// lib/services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _myUid => FirebaseAuth.instance.currentUser?.uid;

  String _buildConversationId(String doctorId, String parentId) {
    return '${doctorId}_$parentId';
  }

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

  Future<void> sendMessage({
    required String conversationId,
    required String text,
    required String senderRole,
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

  /// 🔥 PERBAIKAN: Tandai semua pesan di conversation sebagai sudah dibaca
  Future<void> markConversationAsRead(String conversationId) async {
    final uid = _myUid;
    if (uid == null) return;

    final conversationRef =
    _firestore.collection('conversations').doc(conversationId);

    // Reset unread count untuk user ini
    await conversationRef.update({
      'unreadCount.$uid': 0,
    });

    // Tandai semua pesan yang belum dibaca sebagai read
    // (tanpa filter senderId untuk menghindari index)
    try {
      final unreadMessages = await conversationRef
          .collection('messages')
          .where('read', isEqualTo: false)
          .get();

      if (unreadMessages.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in unreadMessages.docs) {
          batch.update(doc.reference, {'read': true});
        }
        await batch.commit();
      }
    } catch (e) {
      // Error handling - tidak critical karena unreadCount sudah direset
      print('Error marking messages as read: $e');
    }
  }

  /// 🔥 BARU: Tandai SEMUA conversation sebagai sudah dibaca
  Future<void> markAllAsRead() async {
    final uid = _myUid;
    if (uid == null) return;

    try {
      final conversations = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: uid)
          .get();

      for (final doc in conversations.docs) {
        final data = doc.data();
        final unreadCount = Map<String, dynamic>.from(data['unreadCount'] ?? {});

        if (unreadCount.containsKey(uid) && unreadCount[uid] != 0) {
          unreadCount[uid] = 0;
          await doc.reference.update({
            'unreadCount': unreadCount,
          });
        }

        // Tandai semua pesan sebagai read
        try {
          final unreadMessages = await doc.reference
              .collection('messages')
              .where('read', isEqualTo: false)
              .get();

          if (unreadMessages.docs.isNotEmpty) {
            final batch = _firestore.batch();
            for (final msgDoc in unreadMessages.docs) {
              batch.update(msgDoc.reference, {'read': true});
            }
            await batch.commit();
          }
        } catch (e) {
          print('Error marking messages as read in ${doc.id}: $e');
        }
      }
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMyConversations() {
    final uid = _myUid;
    if (uid == null) return Stream.empty();
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

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
    }).handleError((error) {
      print('Error getting unread count: $error');
      return 0;
    });
  }

  Future<int> getUnreadCount(String conversationId) async {
    final uid = _myUid;
    if (uid == null) return 0;

    try {
      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!doc.exists) return 0;

      final data = doc.data();
      if (data == null) return 0;

      final unreadMap = Map<String, dynamic>.from(data['unreadCount'] ?? {});
      return unreadMap[uid] ?? 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      final messages = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      for (final doc in messages.docs) {
        await doc.reference.delete();
      }

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .delete();
    } catch (e) {
      print('Error deleting conversation: $e');
      rethrow;
    }
  }

  Future<void> sendVitalSnapshot({
    required String conversationId,
    required String text,
    required String senderRole,
  }) async {
    return sendMessage(
      conversationId: conversationId,
      text: text,
      senderRole: senderRole,
      isVitalSnapshot: true,
    );
  }
}