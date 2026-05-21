import 'package:equatable/equatable.dart';
import '../../../domain/entities/budget.dart';

class BudgetState extends Equatable {
  final List<BudgetEntity> budgets;
  final bool isLoading;
  final String? errorMessage;
  final bool isSaved;

  const BudgetState({
    this.budgets = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSaved = false,
  });

  factory BudgetState.initial() => const BudgetState();

  BudgetState copyWith({
    List<BudgetEntity>? budgets,
    bool? isLoading,
    String? errorMessage,
    bool? isSaved,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [budgets, isLoading, errorMessage, isSaved];
}
