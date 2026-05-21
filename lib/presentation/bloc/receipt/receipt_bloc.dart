import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/receipt.dart';
import 'receipt_event.dart';
import 'receipt_state.dart';

import '../../../domain/usecases/receipt/get_receipts.dart';
import '../../../domain/usecases/receipt/save_receipt.dart';
import '../../../domain/usecases/receipt/delete_receipt.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final GetReceipts getReceipts;
  final SaveReceipt saveReceipt;
  final DeleteReceiptUseCase deleteReceipt;

  ReceiptBloc({
    required this.getReceipts,
    required this.saveReceipt,
    required this.deleteReceipt,
  }) : super(ReceiptInitial()) {
    on<GetReceiptsRequested>(_onGetReceipts);
    on<SaveReceiptRequested>(_onSaveReceipt);
    on<DeleteReceiptRequested>(_onDeleteReceipt);
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

  Future<void> _onDeleteReceipt(
    DeleteReceiptRequested event,
    Emitter<ReceiptState> emit,
  ) async {
    emit(ReceiptLoading());
    try {
      await deleteReceipt(event.receipt);
      final receipts = await getReceipts();
      emit(ReceiptsLoaded(receipts));
    } catch (e) {
      emit(ReceiptFailure(e.toString()));
    }
  }
}
