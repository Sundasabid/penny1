// lib/main.dart
import 'package:app/presentation/bloc/receipt/receipt_bloc.dart';
import 'package:app/presentation/bloc/transaction_bloc.dart';
import 'package:app/presentation/bloc/transaction_event.dart';
import 'package:app/presentation/pages/receipts/receipts_gallery_page.dart';
import 'package:app/presentation/pages/transaction_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/receipt_repository_impl.dart';
import 'data/services/document_scanner_service.dart';
import 'data/services/ocr_service.dart';
import 'domain/entities/transaction.dart';
import 'domain/repositories/receipt_repository.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/usecases/ transaction/add_transaction.dart';
import 'domain/usecases/ transaction/get_transactions.dart';
import 'domain/usecases/receipt/parse_receipt_text.dart';


void main() {
  runApp(const PennyTestApp());
}

/// ------------------------------------------------------------
/// TEST-ONLY In-Memory Transaction Repository (NO DB)
/// ------------------------------------------------------------
class InMemoryTransactionRepository implements TransactionRepository {
  final List<TransactionEntity> _store = [];

  @override
  Future<void> addTransaction(TransactionEntity tx) async {
    _store.add(tx);
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    // newest first
    final list = List<TransactionEntity>.from(_store);
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }
}

/// ------------------------------------------------------------
/// APP
/// ------------------------------------------------------------
class PennyTestApp extends StatelessWidget {
  const PennyTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ In-memory repos
    final txRepo = InMemoryTransactionRepository();
    final ReceiptRepository receiptRepo = InMemoryReceiptRepository();

    // ✅ Usecases
    final addTx = AddTransactionUseCase(txRepo);
    final getTx = GetTransactionsUseCase(txRepo);

    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>(
          create: (_) => TransactionBloc(
            addTransaction: addTx,
            getTransactions: getTx,
          )..add(const LoadTransactionsRequested()),
        ),
        BlocProvider<ReceiptBloc>(
          create: (ctx) => ReceiptBloc(
            receiptRepository: receiptRepo,
            transactionBloc: ctx.read<TransactionBloc>(),
            scannerService: DocumentScannerService(),
            ocrService: OcrService(),
            receiptParser: const ReceiptParser(),
          )..add(const ReceiptsLoadRequested()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PENNY (Test)',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const _TestHome(),
      ),
    );
  }
}

/// Quick navigation to test scan -> receipt gallery -> history
class _TestHome extends StatelessWidget {
  const _TestHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PENNY Test'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Receipts Gallery (tap + to scan)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReceiptsGalleryPage()),
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('Transaction History (manual + receipt)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TransactionHistoryPage()),
            ),
          ),
        ],
      ),
    );
  }
}
