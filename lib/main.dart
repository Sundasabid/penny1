// lib/main.dart
import 'package:app/presentation/bloc/transaction_bloc.dart';
import 'package:app/presentation/pages/add_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/themes/app_theme.dart';
import 'data/data_sources/local/local_data_source.dart';
import 'data/data_sources/remote/firestore_source.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'domain/usecases/ transaction/add_transaction.dart';
import 'domain/usecases/ transaction/get_transactions.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PennyApp());
}

class PennyApp extends StatelessWidget {
  const PennyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ---------- Manual dependency wiring (no injector) ----------
    final local = InMemoryLocalDataSource();
    final remote = FirestoreSource();

    final repo = TransactionRepositoryImpl(local: local, remote: remote);

    final addTx = AddTransactionUseCase(repo);
    final getTx = GetTransactionsUseCase(repo);

    return BlocProvider<TransactionBloc>(
      create: (_) => TransactionBloc(
        addTransaction: addTx,
        getTransactions: getTx,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PENNY',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light, // change to ThemeMode.system later
        home: const AddExpensePage(),
      ),
    );
  }
}
