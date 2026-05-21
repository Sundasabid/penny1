// lib/presentation/bloc/chat/chat_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

import '../../../domain/entities/chat_session.dart';

class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final List<ChatSession> sessions;
  final String? currentSessionId;
  final bool isLoading;
  final String? errorMessage;

  const ChatState({
    required this.messages,
    required this.sessions,
    this.currentSessionId,
    required this.isLoading,
    this.errorMessage,
  });

  factory ChatState.initial() {
    return const ChatState(messages: [], sessions: [], isLoading: false);
  }

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<ChatSession>? sessions,
    Object? currentSessionId = _undefined,
    bool? isLoading,
    Object? errorMessage = _undefined,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      sessions: sessions ?? this.sessions,
      currentSessionId: currentSessionId == _undefined
          ? this.currentSessionId
          : (currentSessionId as String?),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _undefined
          ? this.errorMessage
          : (errorMessage as String?),
    );
  }

  static const _undefined = Object();

  @override
  List<Object?> get props => [
    messages,
    sessions,
    currentSessionId,
    isLoading,
    errorMessage,
  ];
}
