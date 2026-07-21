// lib/models/chat_message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderRole; // 'doctor' atau 'parent'
  final String text;
  final DateTime sentAt;
  final bool read;
  final bool isVitalSnapshot;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.sentAt,
    required this.read,
    this.isVitalSnapshot = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderRole': senderRole,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
      'read': read,
      'isVitalSnapshot': isVitalSnapshot,
    };
  }

  factory ChatMessage.fromDoc(String id, Map<String, dynamic> data) {
    return ChatMessage(
      id: id,
      senderId: data['senderId'] ?? '',
      senderRole: data['senderRole'] ?? 'parent',
      text: data['text'] ?? '',
      sentAt: (data['sentAt'] is Timestamp)
          ? (data['sentAt'] as Timestamp).toDate()
          : DateTime.now(),
      read: data['read'] ?? false,
      isVitalSnapshot: data['isVitalSnapshot'] ?? false,
    );
  }
}