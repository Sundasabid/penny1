import 'package:equatable/equatable.dart';
import '../../../domain/entities/debt.dart';

abstract class DebtEvent extends Equatable {
  const DebtEvent();

  @override
  List<Object?> get props => [];
}

class LoadDebtsRequested extends DebtEvent {}

class AddDebtRequested extends DebtEvent {
  final DebtEntity debt;
  const AddDebtRequested(this.debt);

  @override
  List<Object?> get props => [debt];
}

class UpdateDebtRequested extends DebtEvent {
  final DebtEntity debt;
  const UpdateDebtRequested(this.debt);

  @override
  List<Object?> get props => [debt];
}

class DeleteDebtRequested extends DebtEvent {
  final String id;
  const DeleteDebtRequested(this.id);

  @override
  List<Object?> get props => [id];
}
