import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:rental_app/features/renter/application/providers/inquiry_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String inquiryId;
  const ChatScreen({super.key, required this.inquiryId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      ref.read(inquiryProvider.notifier).sendMessage(widget.inquiryId, text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final inquiries = ref.watch(inquiryProvider);
    final inquiry = inquiries.firstWhere((i) => i.id == widget.inquiryId);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inquiry.listing.title, style: const TextStyle(fontSize: 16)),
            Text(inquiry.listing.location, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: inquiry.messages.length,
              itemBuilder: (context, index) {
                final message = inquiry.messages[index];
                return Align(
                  alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: message.isMe ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: message.isMe ? const Radius.circular(0) : const Radius.circular(16),
                        bottomLeft: message.isMe ? const Radius.circular(16) : const Radius.circular(0),
                      ),
                      boxShadow: [
                        if (!message.isMe)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(color: message.isMe ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
