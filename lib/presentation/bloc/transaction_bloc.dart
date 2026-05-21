// lib/src/presentation/pages/bloc/transaction_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../domain/usecases/transaction/add_transaction.dart';
import '../../domain/usecases/transaction/get_transactions.dart';
import '../../domain/usecases/transaction/delete_transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final AddTransactionUseCase addTransaction;
  final GetTransactionsUseCase getTransactions;
  final DeleteTransactionUseCase deleteTransaction;

  TransactionBloc({
    required this.addTransaction,
    required this.getTransactions,
    required this.deleteTransaction,
  }) : super(TransactionState.initial()) {
    on<LoadTransactionsRequested>(_onLoadTransactions);
    on<AddTransactionRequested>(_onAddTransaction);
    on<DeleteTransactionRequested>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      state.copyWith(isLoading: true, errorMessage: null, addSuccess: false),
    );

    try {
      final items = await getTransactions();
      emit(state.copyWith(isLoading: false, transactions: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddTransaction(
    AddTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      state.copyWith(isLoading: true, errorMessage: null, addSuccess: false),
    );

    try {
      await addTransaction(event.transaction);
      final items = await getTransactions();

      emit(
        state.copyWith(isLoading: false, transactions: items, addSuccess: true),
      );
    } catch (e, stackTrace) {
      debugPrint("❌ TransactionBloc Error: $e");
      debugPrint("Stacktrace: $stackTrace");
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          addSuccess: false,
        ),
      );
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      state.copyWith(isLoading: true, errorMessage: null, addSuccess: false),
    );

    try {
      await deleteTransaction(event.transaction);
      final items = await getTransactions();

      emit(
        state.copyWith(
          isLoading: false,
          transactions: items,
          deleteSuccess: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          deleteSuccess: false,
        ),
      );
    }
  }
}
