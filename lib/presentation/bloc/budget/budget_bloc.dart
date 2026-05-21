import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/budget_repository.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository budgetRepository;

  BudgetBloc({required this.budgetRepository}) : super(BudgetState.initial()) {
    on<LoadBudgetsRequested>(_onLoadBudgets);
    on<SaveBudgetRequested>(_onSaveBudget);
    on<DeleteBudgetRequested>(_onDeleteBudget);
  }

  Future<void> _onLoadBudgets(
    LoadBudgetsRequested event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isSaved: false));
    try {
      final budgets = await budgetRepository.getBudgets();
      emit(state.copyWith(isLoading: false, budgets: budgets));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSaveBudget(
    SaveBudgetRequested event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isSaved: false));
    try {
      await budgetRepository.saveBudget(event.budget);
      final budgets = await budgetRepository.getBudgets();
      emit(state.copyWith(isLoading: false, budgets: budgets, isSaved: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteBudget(
    DeleteBudgetRequested event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await budgetRepository.deleteBudget(event.budgetId);
      final budgets = await budgetRepository.getBudgets();
      emit(state.copyWith(isLoading: false, budgets: budgets));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
