import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';

/// Single immutable state for TransactionBloc
class TransactionState extends Equatable {
  final bool isLoading;
  final List<TransactionEntity> transactions;
  final String? errorMessage;

  /// Used by AddExpensePage or History to know when to navigate or refresh
  final bool addSuccess;
  final bool deleteSuccess;

  const TransactionState({
    required this.isLoading,
    required this.transactions,
    required this.errorMessage,
    required this.addSuccess,
    required this.deleteSuccess,
  });

  factory TransactionState.initial() {
    return const TransactionState(
      isLoading: false,
      transactions: [],
      errorMessage: null,
      addSuccess: false,
      deleteSuccess: false,
    );
  }

  TransactionState copyWith({
    bool? isLoading,
    List<TransactionEntity>? transactions,
    String? errorMessage,
    bool? addSuccess,
    bool? deleteSuccess,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
      addSuccess: addSuccess ?? false,
      deleteSuccess: deleteSuccess ?? false,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    transactions,
    errorMessage,
    addSuccess,
    deleteSuccess,
  ];
}
