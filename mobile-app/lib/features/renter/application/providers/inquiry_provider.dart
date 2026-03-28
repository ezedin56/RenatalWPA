import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/listing_model.dart';

class InquiryModel {
  final String id;
  final ListingModel listing;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isNew;
  final List<ChatMessage> messages;

  InquiryModel({
    required this.id,
    required this.listing,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isNew = false,
    this.messages = const [],
  });

  InquiryModel copyWith({
    List<ChatMessage>? messages,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? isNew,
  }) {
    return InquiryModel(
      id: id,
      listing: listing,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isNew: isNew ?? this.isNew,
      messages: messages ?? this.messages,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({required this.text, required this.isMe, required this.time});
}

class InquiryNotifier extends Notifier<List<InquiryModel>> {
  @override
  List<InquiryModel> build() {
    return [];
  }

  void addInquiry(ListingModel listing, String message) {
    final newInquiry = InquiryModel(
      id: DateTime.now().toString(),
      listing: listing,
      lastMessage: message,
      lastMessageTime: DateTime.now(),
      isNew: true,
      messages: [ChatMessage(text: message, isMe: true, time: DateTime.now())],
    );
    state = [newInquiry, ...state];
  }

  void sendMessage(String inquiryId, String message) {
    state = [
      for (final inquiry in state)
        if (inquiry.id == inquiryId)
          inquiry.copyWith(
            messages: [...inquiry.messages, ChatMessage(text: message, isMe: true, time: DateTime.now())],
            lastMessage: message,
            lastMessageTime: DateTime.now(),
            isNew: false,
          )
        else
          inquiry
    ];
  }
}

final inquiryProvider = NotifierProvider<InquiryNotifier, List<InquiryModel>>(InquiryNotifier.new);
