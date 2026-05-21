import 'package:equatable/equatable.dart';
import '../../../domain/entities/budget.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();
  @override
  List<Object?> get props => [];
}

class LoadBudgetsRequested extends BudgetEvent {}

class SaveBudgetRequested extends BudgetEvent {
  final BudgetEntity budget;
  const SaveBudgetRequested(this.budget);
  @override
  List<Object?> get props => [budget];
}

class DeleteBudgetRequested extends BudgetEvent {
  final String budgetId;
  const DeleteBudgetRequested(this.budgetId);
  @override
  List<Object?> get props => [budgetId];
}
