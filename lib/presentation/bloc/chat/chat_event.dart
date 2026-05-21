import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessageRequested extends ChatEvent {
  final String message;
  final List<TransactionEntity> transactions;

  const SendMessageRequested({
    required this.message,
    required this.transactions,
  });

  @override
  List<Object?> get props => [message, transactions];
}

class LoadSessionsRequested extends ChatEvent {}

class SelectSessionRequested extends ChatEvent {
  final String sessionId;
  const SelectSessionRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class CreateNewSessionRequested extends ChatEvent {
  final String? title;
  const CreateNewSessionRequested({this.title});

  @override
  List<Object?> get props => [title];
}

class DeleteSessionRequested extends ChatEvent {
  final String sessionId;
  const DeleteSessionRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class DeselectSessionRequested extends ChatEvent {}

class UpdateSessionTitleRequested extends ChatEvent {
  final String sessionId;
  final String title;

  const UpdateSessionTitleRequested({
    required this.sessionId,
    required this.title,
  });

  @override
  List<Object?> get props => [sessionId, title];
}

class TogglePinSessionRequested extends ChatEvent {
  final String sessionId;
  final bool isPinned;

  const TogglePinSessionRequested({
    required this.sessionId,
    required this.isPinned,
  });

  @override
  List<Object?> get props => [sessionId, isPinned];
}

class ClearChatRequested extends ChatEvent {}
