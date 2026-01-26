// lib/presentation/blocs/receipt/receipt_state.dart
part of 'receipt_bloc.dart';

enum ReceiptStatus { initial, scanning, loaded, error }

class ReceiptState extends Equatable {
  final ReceiptStatus status;
  final List<ReceiptEntity> receipts;
  final String? errorMessage;

  const ReceiptState({
    required this.status,
    required this.receipts,
    this.errorMessage,
  });

  const ReceiptState.initial()
      : status = ReceiptStatus.initial,
        receipts = const [],
        errorMessage = null;

  ReceiptState copyWith({
    ReceiptStatus? status,
    List<ReceiptEntity>? receipts,
    String? errorMessage,
  }) {
    return ReceiptState(
      status: status ?? this.status,
      receipts: receipts ?? this.receipts,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, receipts, errorMessage];
}
