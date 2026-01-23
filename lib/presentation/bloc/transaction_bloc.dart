import 'package:flutter_bloc/flutter_bloc.dart';


import '../../domain/usecases/ transaction/add_transaction.dart';
import '../../domain/usecases/ transaction/get_transactions.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final AddTransactionUseCase addTransaction;
  final GetTransactionsUseCase getTransactions;

  TransactionBloc({
    required this.addTransaction,
    required this.getTransactions,
  }) : super(TransactionState.initial()) {
    on<LoadTransactionsRequested>(_onLoadTransactions);
    on<AddTransactionRequested>(_onAddTransaction);
  }

  Future<void> _onLoadTransactions(
      LoadTransactionsRequested event,
      Emitter<TransactionState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final items = await getTransactions();
      emit(
        state.copyWith(
          isLoading: false,
          transactions: items,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddTransaction(
      AddTransactionRequested event,
      Emitter<TransactionState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, addSuccess: false));

    try {
      await addTransaction(event.transaction);
      final items = await getTransactions();

      emit(
        state.copyWith(
          isLoading: false,
          transactions: items,
          addSuccess: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
