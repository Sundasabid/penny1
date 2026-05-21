import 'package:flutter_bloc/flutter_bloc.dart';
import 'debt_event.dart';
import 'debt_state.dart';
import '../../../domain/repositories/debt_repository.dart';

class DebtBloc extends Bloc<DebtEvent, DebtState> {
  final DebtRepository repository;

  DebtBloc({required this.repository}) : super(DebtState.initial()) {
    on<LoadDebtsRequested>(_onLoadDebts);
    on<AddDebtRequested>(_onAddDebt);
    on<UpdateDebtRequested>(_onUpdateDebt);
    on<DeleteDebtRequested>(_onDeleteDebt);
  }

  Future<void> _onLoadDebts(
      LoadDebtsRequested event, Emitter<DebtState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, addSuccess: false));
    try {
      final items = await repository.getDebts();
      emit(state.copyWith(isLoading: false, debts: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddDebt(AddDebtRequested event, Emitter<DebtState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, addSuccess: false));
    try {
      await repository.addDebt(event.debt);
      final items = await repository.getDebts();
      emit(state.copyWith(isLoading: false, debts: items, addSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateDebt(
      UpdateDebtRequested event, Emitter<DebtState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.updateDebt(event.debt);
      final items = await repository.getDebts();
      emit(state.copyWith(isLoading: false, debts: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteDebt(
      DeleteDebtRequested event, Emitter<DebtState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.deleteDebt(event.id);
      final items = await repository.getDebts();
      emit(state.copyWith(isLoading: false, debts: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
