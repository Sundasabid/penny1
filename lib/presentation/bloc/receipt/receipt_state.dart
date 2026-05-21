abstract class ReceiptState {}

class ReceiptInitial extends ReceiptState {}

class ReceiptLoading extends ReceiptState {}

class ReceiptFailure extends ReceiptState {
  final String message;
  ReceiptFailure(this.message);
}

class ReceiptsLoaded extends ReceiptState {
  final List<dynamic> receipts;
  ReceiptsLoaded(this.receipts);
}
