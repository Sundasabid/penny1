import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/receipt.dart';
import 'receipt_event.dart';
import 'receipt_state.dart';

import '../../../domain/usecases/receipt/get_receipts.dart';
import '../../../domain/usecases/receipt/save_receipt.dart';


class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final GetReceipts getReceipts;
  final SaveReceipt saveReceipt;

  ReceiptBloc({
    required this.getReceipts,
    required this.saveReceipt,
  }) : super(ReceiptInitial()) {
    on<GetReceiptsRequested>(_onGetReceipts);
    on<SaveReceiptRequested>(_onSaveReceipt);
  }

  Future<void> _onGetReceipts(
      GetReceiptsRequested event,
      Emitter<ReceiptState> emit,
      ) async {
    emit(ReceiptLoading());
    try {
      final receipts = await getReceipts(); // ✅ NO PARAMS
      emit(ReceiptsLoaded(receipts));
    } catch (e) {
      emit(ReceiptFailure(e.toString()));
    }
  }

  Future<void> _onSaveReceipt(
      SaveReceiptRequested event,
      Emitter<ReceiptState> emit,
      ) async {
    emit(ReceiptLoading());
    try {
      await saveReceipt(
        ReceiptEntity(
          id: event.receiptId,
          imagePath: event.imagePath,
          merchantName: event.merchantName,
          amount: event.amount,
          category: event.category,
          dateTime: event.dateTime,
        ),
      );

      // reload gallery immediately
      final receipts = await getReceipts(); // ✅ NO PARAMS
      emit(ReceiptsLoaded(receipts));
    } catch (e) {
      emit(ReceiptFailure(e.toString()));
    }
  }
}
