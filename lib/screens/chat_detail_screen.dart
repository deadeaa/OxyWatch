// screens/chat_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dokter_model.dart';
import '../providers/auth_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final Dokter dokter;

  const ChatDetailScreen({super.key, required this.dokter});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    _messages.addAll([
      {
        'from': 'doctor',
        'name': 'Dr. Siti',
        'text': 'Selamat pagi. Bagaimana kondisi Budi setelah inhalasi semalam?',
        'time': '09:12',
      },
      {
        'from': 'parent',
        'name': 'Ibu Rina',
        'text': 'Dok, Budi masih batuk dan saturasinya sempat turun ke 89%. Saya khawatir.',
        'time': '09:15',
      },
      {
        'from': 'snapshot',
        'name': 'Budi Santoso · PED-0123',
        'text': 'Snapshot: SpO₂ 89% · HR 162 bpm',
        'time': '09:15',
      },
      {
        'from': 'doctor',
        'name': 'Dr. Siti',
        'text': 'Terima kasih snapshot-nya. Tetap pantau dan beri inhalasi lagi jika sesak. Saya update jadwal kontrol ya.',
        'time': '09:18',
      },
      {
        'from': 'parent',
        'name': 'Ibu Rina',
        'text': 'Baik dok, terima kasih. Nanti saya kabari lagi perkembangannya.',
        'time': '09:20',
      },
    ]);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'from': 'parent',
          'name': 'Ibu Rina',
          'text': _messageController.text.trim(),
          'time': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        });
        _messageController.clear();
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final patientName = auth.nama.isNotEmpty ? auth.nama : 'Budi Santoso';
    final patientId = auth.patientId.isNotEmpty ? auth.patientId : 'PED-0123';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B3A5C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2E5A8A),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.medical_services,
                  color: Color(0xFF4FC3F7),
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.dokter.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '$patientName · $patientId',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.3)),
            ),
            child: Row(
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
                    color: Color(0xFF22C55E),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSnapshot = message['from'] == 'snapshot';
                final isParent = message['from'] == 'parent';
                final isDoctor = message['from'] == 'doctor';

                if (index == 0) {
                  return Column(
                    children: [
                      _buildDateDivider('Hari ini, 17 Juni 2025'),
                      const SizedBox(height: 16),
                      isSnapshot
                          ? _buildSnapshotMessage(message)
                          : _buildChatBubble(message, isParent, isDoctor),
                    ],
                  );
                }

                return isSnapshot
                    ? _buildSnapshotMessage(message)
                    : _buildChatBubble(message, isParent, isDoctor);
              },
            ),
          ),
          // Input
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildDateDivider(String date) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFDDE4F0),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          date,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFDDE4F0),
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> message, bool isParent, bool isDoctor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isParent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDoctor)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF2E5A8A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.dokter.foto,
                  style: const TextStyle(
                    color: Color(0xFF4FC3F7),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          if (isDoctor) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isParent ? const Color(0xFF1B3A5C) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isParent ? const Radius.circular(16) : const Radius.circular(0),
                  bottomRight: isParent ? const Radius.circular(0) : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDoctor)
                    Text(
                      message['name'],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4FC3F7),
                      ),
                    ),
                  if (isDoctor) const SizedBox(height: 2),
                  Text(
                    message['text'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isParent ? Colors.white : const Color(0xFF1B3A5C),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 🔥 FIX: TextAlign dipindah ke Text widget
                  Text(
                    message['time'],
                    style: TextStyle(
                      fontSize: 9,
                      color: isParent ? Colors.white.withOpacity(0.7) : const Color(0xFF94A3B8),
                    ),
                    textAlign: isParent ? TextAlign.right : TextAlign.left,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotMessage(Map<String, dynamic> message) {
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
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(0),
                ),
                border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.1875)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Color(0xFF4FC3F7),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'DATA VITAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4FC3F7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['text'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B3A5C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${message['name']} · ${message['time']}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF64748B),
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

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          // Tombol Vital
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF8FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.1875)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Color(0xFF4FC3F7),
                  size: 13,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Vital',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4FC3F7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Input
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(
                color: Color(0xFF1B3A5C),
                fontSize: 12,
              ),
              decoration: InputDecoration(
                hintText: 'Tulis pesan ke dokter...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1B3A5C)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: const Color(0xFFF4F7FF),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _messageController.text.trim().isNotEmpty
                  ? const Color(0xFF1B3A5C)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: _messageController.text.trim().isNotEmpty
                    ? Colors.white
                    : const Color(0xFF94A3B8),
                size: 16,
              ),
              padding: EdgeInsets.zero,
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}