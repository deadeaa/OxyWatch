// screens/chat_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../models/chat_message_model.dart';
import '../models/user_model.dart';
// screens/chat_detail_screen.dart
class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final String otherPersonName;
  final String otherPersonSubtitle;
  final VoidCallback? onBack;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.otherPersonName,
    this.otherPersonSubtitle = '',
    this.onBack,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    // Gunakan widget.conversationId, bukan variabel lokal
    _chatService.markConversationAsRead(widget.conversationId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String myRole) {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    _chatService.sendMessage(
      conversationId: widget.conversationId,
      text: text,
      senderRole: myRole,
    );
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final myUid = auth.currentUser?.uid ?? '';
    final myRole = auth.currentUser?.role == UserRole.doctor ? 'doctor' : 'parent';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B3A5C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            }
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF2E5A8A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.otherPersonName.isNotEmpty ? widget.otherPersonName[0] : '?',
                  style: const TextStyle(
                    color: Color(0xFF4FC3F7),
                    fontWeight: FontWeight.bold,
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
                    widget.otherPersonName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (widget.otherPersonSubtitle.isNotEmpty)
                    Text(
                      widget.otherPersonSubtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.streamMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada pesan. Mulai percakapan sekarang.',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  );
                }

                // Auto-scroll ke bawah tiap ada pesan baru.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = message.senderId == myUid;

                    final showDateDivider = index == 0 ||
                        !_isSameDay(messages[index - 1].sentAt, message.sentAt);

                    return Column(
                      children: [
                        if (showDateDivider) ...[
                          _buildDateDivider(_formatDate(message.sentAt)),
                          const SizedBox(height: 16),
                        ],
                        message.isVitalSnapshot
                            ? _buildSnapshotMessage(message)
                            : _buildChatBubble(message, isMine),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildChatInput(myRole),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final now = DateTime.now();
    final formatted = '${date.day} ${bulan[date.month - 1]} ${date.year}';
    if (_isSameDay(date, now)) return 'Hari ini, $formatted';
    return formatted;
  }

  String _formatTime(DateTime date) => DateFormat('HH:mm').format(date);

  Widget _buildDateDivider(String date) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFFDDE4F0))),
        const SizedBox(width: 12),
        Text(date, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: const Color(0xFFDDE4F0))),
      ],
    );
  }

  Widget _buildChatBubble(ChatMessage message, bool isMine) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMine ? const Color(0xFF1B3A5C) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMine ? const Radius.circular(16) : const Radius.circular(0),
                  bottomRight: isMine ? const Radius.circular(0) : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 12,
                      color: isMine ? Colors.white : const Color(0xFF1B3A5C),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.sentAt),
                    style: TextStyle(
                      fontSize: 9,
                      color: isMine ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4FC3F7).withValues(alpha: 0.19)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.favorite, color: Color(0xFF4FC3F7), size: 12),
                      SizedBox(width: 4),
                      Text('DATA VITAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF4FC3F7))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.text,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1B3A5C)),
                  ),
                  const SizedBox(height: 2),
                  Text(_formatTime(message.sentAt), style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput(String myRole) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Color(0xFF1B3A5C), fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Tulis pesan...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1B3A5C))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: const Color(0xFFF4F7FF),
              ),
              onSubmitted: (_) => _sendMessage(myRole),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1B3A5C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white, size: 16),
              padding: EdgeInsets.zero,
              onPressed: () => _sendMessage(myRole),
            ),
          ),
        ],
      ),
    );
  }
}