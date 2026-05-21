// lib/presentation/bloc/chat/chat_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/chat_session.dart';
import '../../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;

  ChatBloc({required this.chatRepository}) : super(ChatState.initial()) {
    on<SendMessageRequested>(_onSendMessage);
    on<LoadSessionsRequested>(_onLoadSessions);
    on<SelectSessionRequested>(_onSelectSession);
    on<CreateNewSessionRequested>(_onCreateNewSession);
    on<DeleteSessionRequested>(_onDeleteSession);
    on<DeselectSessionRequested>(_onDeselectSession);
    on<UpdateSessionTitleRequested>(_onUpdateSessionTitle);
    on<TogglePinSessionRequested>(_onTogglePinSession);
    on<ClearChatRequested>(_onClearChat);
  }

  void _onDeselectSession(
    DeselectSessionRequested event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(currentSessionId: null, messages: []));
  }

  Future<void> _onLoadSessions(
    LoadSessionsRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final sessions = await chatRepository.getSessions();
      emit(state.copyWith(sessions: sessions));
    } catch (e) {
      emit(state.copyWith(errorMessage: "Failed to load chat history: ${e.toString()}"));
    }
  }

  Future<void> _onSelectSession(
    SelectSessionRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        currentSessionId: event.sessionId,
        messages: [],
      ),
    );
    try {
      final messages = await chatRepository.getMessages(event.sessionId);
      emit(state.copyWith(messages: messages, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: "Failed to load messages.",
        ),
      );
    }
  }

  Future<void> _onCreateNewSession(
    CreateNewSessionRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final title =
          event.title ??
          "New Chat ${DateTime.now().hour}:${DateTime.now().minute}";
      final session = await chatRepository.createSession(title);
      final updatedSessions = List<ChatSession>.from(state.sessions)
        ..insert(0, session);
      emit(
        state.copyWith(
          sessions: updatedSessions,
          currentSessionId: session.id,
          messages: [],
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: "Failed to create new chat: ${e.toString()}",
        ),
      );
    }
  }

  Future<void> _onDeleteSession(
    DeleteSessionRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await chatRepository.deleteSession(event.sessionId);
      final updatedSessions = state.sessions
          .where((s) => s.id != event.sessionId)
          .toList();
      emit(
        state.copyWith(
          sessions: updatedSessions,
          currentSessionId: state.currentSessionId == event.sessionId
              ? null
              : state.currentSessionId,
          messages: state.currentSessionId == event.sessionId
              ? []
              : state.messages,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: "Failed to delete session."));
    }
  }

  Future<void> _onUpdateSessionTitle(
    UpdateSessionTitleRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await chatRepository.updateSessionTitle(event.sessionId, event.title);
      final updatedSessions = state.sessions.map((s) {
        if (s.id == event.sessionId) {
          return s.copyWith(title: event.title);
        }
        return s;
      }).toList();
      emit(state.copyWith(sessions: updatedSessions));
    } catch (e) {
      emit(state.copyWith(errorMessage: "Failed to update chat title."));
    }
  }

  Future<void> _onTogglePinSession(
    TogglePinSessionRequested event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await chatRepository.updateSessionPinStatus(event.sessionId, event.isPinned);
      // Instead of manual sorting here, we re-load sessions to ensure correct Firestore order
      // OR we can manually sort if we want immediate UI update. 
      // Manual sort:
      final updatedSessions = state.sessions.map((s) {
        if (s.id == event.sessionId) {
          return s.copyWith(isPinned: event.isPinned);
        }
        return s;
      }).toList();
      
      // Sort: pinned first, then by updatedAt
      updatedSessions.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });

      emit(state.copyWith(sessions: updatedSessions));
    } catch (e) {
      emit(state.copyWith(errorMessage: "Failed to update pin status."));
    }
  }

  Future<void> _onSendMessage(
    SendMessageRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (event.message.trim().isEmpty) return;

    // 1. Ensure we have a session
    String? sessionId = state.currentSessionId;
    try {
      if (sessionId == null) {
        final title = _generateTitle(event.message);
        final newSession = await chatRepository.createSession(title);
        sessionId = newSession.id;
        final updatedSessions = List<ChatSession>.from(state.sessions)
          ..insert(0, newSession);
        emit(
          state.copyWith(
            currentSessionId: sessionId,
            sessions: updatedSessions,
          ),
        );
      } else {
        // Check if we need to update the title (if it was a "New Chat" placeholder)
        final session = state.sessions.firstWhere((s) => s.id == sessionId);
        if (session.title.startsWith("New Chat") && state.messages.isEmpty) {
          final newTitle = _generateTitle(event.message);
          await chatRepository.updateSessionTitle(sessionId, newTitle);

          final updatedSessions = state.sessions.map((s) {
            if (s.id == sessionId) {
              return ChatSession(
                id: s.id,
                title: newTitle,
                messages: s.messages,
                updatedAt: DateTime.now(),
              );
            }
            return s;
          }).toList();

          emit(state.copyWith(sessions: updatedSessions));
        }
      }

      final userMessage = ChatMessage(
        text: event.message,
        role: MessageRole.user,
        timestamp: DateTime.now(),
      );

      final updatedMessages = List<ChatMessage>.from(state.messages)
        ..add(userMessage);

      emit(
        state.copyWith(
          messages: updatedMessages,
          isLoading: true,
          errorMessage: null,
        ),
      );

      // Save user message to Firestore
      await chatRepository.saveMessage(sessionId, userMessage);

      final response = await chatRepository.getChatResponse(
        history: updatedMessages,
        message: event.message,
        transactions: event.transactions,
      );

      // Save model response to Firestore
      await chatRepository.saveMessage(sessionId, response);

      emit(
        state.copyWith(
          messages: List<ChatMessage>.from(updatedMessages)..add(response),
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst("Exception: ", ""),
        ),
      );
    }
  }

  String _generateTitle(String firstMessage) {
    if (firstMessage.length <= 30) {
      return firstMessage.replaceAll('\n', ' ');
    }
    return "${firstMessage.substring(0, 27).replaceAll('\n', ' ')}...";
  }

  void _onClearChat(ClearChatRequested event, Emitter<ChatState> emit) {
    emit(ChatState.initial());
  }
}
