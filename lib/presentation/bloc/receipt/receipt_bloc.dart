import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../data/services/document_scanner_service.dart';
import '../../../data/services/ocr_service.dart';
import '../../../domain/entities/receipt.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/receipt_repository.dart';

import '../../../domain/usecases/receipt/parse_receipt_text.dart';
import '../transaction/transaction_bloc.dart';
import '../transaction_bloc.dart';
import '../transaction_event.dart';

part 'receipt_event.dart';
part 'receipt_state.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final ReceiptRepository receiptRepository;
  final TransactionBloc transactionBloc;
  final DocumentScannerService scannerService;
  final OcrService ocrService;
  final ReceiptParser receiptParser;

  ReceiptBloc({
    required this.receiptRepository,
    required this.transactionBloc,
    required this.scannerService,
    required this.ocrService,
    required this.receiptParser,
  }) : super(const ReceiptState.initial()) {
    on<ReceiptsLoadRequested>(_onLoad);
    on<ReceiptScanRequested>(_onScan);
  }

  Future<void> _onLoad(
      ReceiptsLoadRequested event,
      Emitter<ReceiptState> emit,
      ) async {
    try {
      final receipts = await receiptRepository.getReceipts();
      emit(state.copyWith(status: ReceiptStatus.loaded, receipts: receipts));
    } catch (e) {
      emit(state.copyWith(
        status: ReceiptStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onScan(
      ReceiptScanRequested event,
      Emitter<ReceiptState> emit,
      ) async {
    emit(state.copyWith(status: ReceiptStatus.scanning, errorMessage: null));

    try {
      // 1) Scan receipt image
      final imagePath = await scannerService.scanReceipt();
      if (imagePath == null) {
        // User cancelled
        final receipts = await receiptRepository.getReceipts();
        emit(state.copyWith(status: ReceiptStatus.loaded, receipts: receipts));
        return;
      }

      // 2) OCR -> raw text
      final rawText = await ocrService.extractText(imagePath);

      // 3) Parse -> merchant/amount/date/category
      final parsed = receiptParser.parse(rawText);

      // 4) Create receipt record (local / in-memory)
      final receipt = ReceiptEntity(
        id: const Uuid().v4(),
        merchant: parsed.merchant,
        amount: parsed.amount,
        date: parsed.date,
        imagePath: imagePath,
        rawText: rawText,
      );

      await receiptRepository.addReceipt(receipt);

      // 5) Create a transaction so it appears in History
      // IMPORTANT: match your TransactionEntity fields exactly
      transactionBloc.add(
        AddTransactionRequested(
          TransactionEntity(
            id: const Uuid().v4(),
            merchant: receipt.merchant,
            category: parsed.category,
            amount: receipt.amount,
            dateTime: receipt.date,
            paymentMethod: 'Receipt',
            isIncome: false,
            source: TransactionSource.receipt,
            receiptId: receipt.id,
          ),
        ),
      );

      // 6) Reload receipts and emit updated gallery state
      final receipts = await receiptRepository.getReceipts();
      emit(state.copyWith(status: ReceiptStatus.loaded, receipts: receipts));
    } catch (e) {
      emit(state.copyWith(
        status: ReceiptStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
