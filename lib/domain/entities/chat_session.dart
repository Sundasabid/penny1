// lib/domain/entities/chat_session.dart
import 'chat_message.dart';

class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime updatedAt;
  final bool isPinned;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
    this.isPinned = false,
  });

  ChatSession copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
