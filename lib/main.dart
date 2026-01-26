// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/receipt_repository_impl.dart';

import 'domain/entities/transaction.dart';
import 'domain/repositories/transaction_repository.dart';

import 'domain/usecases/ transaction/add_transaction.dart';
import 'domain/usecases/ transaction/get_transactions.dart';
import 'domain/usecases/transaction/add_transaction.dart';
import 'domain/usecases/transaction/get_transactions.dart';

import 'domain/usecases/receipt/get_receipts.dart';
import 'domain/usecases/receipt/save_receipt.dart';

import 'presentation/bloc/receipt/receipt_bloc.dart';
import 'presentation/bloc/receipt/receipt_event.dart';

import 'presentation/bloc/transaction_bloc.dart';
import 'presentation/bloc/transaction_event.dart';

import 'app_shell.dart';

void main() {
  runApp(const PennyTestApp());
}

/// ------------------------------------------------------------
/// TEST-ONLY In-Memory Transaction Repository
/// (manual + receipt transactions will both be stored here)
/// ------------------------------------------------------------
class InMemoryTransactionRepository implements TransactionRepository {
  final List<TransactionEntity> _store = [];

  @override
  Future<void> addTransaction(TransactionEntity tx) async {
    _store.add(tx);
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final list = List<TransactionEntity>.from(_store);
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }
}

class PennyTestApp extends StatelessWidget {
  const PennyTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    // In-memory repositories
    final txRepo = InMemoryTransactionRepository();
    final receiptRepo = InMemoryReceiptRepository();

    // Transaction usecases
    final addTx = AddTransactionUseCase(txRepo);
    final getTx = GetTransactionsUseCase(txRepo);

    // Receipt usecases
    final getReceipts = GetReceipts(receiptRepo);
    final saveReceipt = SaveReceipt(receiptRepo);

    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>(
          create: (_) => TransactionBloc(
            addTransaction: addTx,
            getTransactions: getTx,
          )..add(const LoadTransactionsRequested()),
        ),
        BlocProvider<ReceiptBloc>(
          create: (_) => ReceiptBloc(
            getReceipts: getReceipts,
            saveReceipt: saveReceipt,
          )..add(GetReceiptsRequested()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PENNY',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        // ✅ Home is now the dashboard flow (bottom nav shell)
        home: const AppShell(),
      ),
    );
  }
}
