// lib/presentation/blocs/receipt/receipt_event.dart
part of 'receipt_bloc.dart';

abstract class ReceiptEvent extends Equatable {
  const ReceiptEvent();

  @override
  List<Object?> get props => [];
}

class ReceiptsLoadRequested extends ReceiptEvent {
  const ReceiptsLoadRequested();
}

class ReceiptScanRequested extends ReceiptEvent {
  const ReceiptScanRequested();
}
