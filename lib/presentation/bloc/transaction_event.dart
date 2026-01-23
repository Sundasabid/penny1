import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';

/// Base class for all transaction-related events
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when History page opens
/// or when list needs to be refreshed
class LoadTransactionsRequested extends TransactionEvent {
  const LoadTransactionsRequested();
}

/// Fired when user presses "Save Expense"
class AddTransactionRequested extends TransactionEvent {
  final TransactionEntity transaction;

  const AddTransactionRequested(this.transaction);

  @override
  List<Object?> get props => [transaction];
}
