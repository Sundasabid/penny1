import 'package:equatable/equatable.dart';
import '../../../domain/entities/debt.dart';

class DebtState extends Equatable {
  final List<DebtEntity> debts;
  final bool isLoading;
  final String? errorMessage;
  final bool addSuccess;

  const DebtState({
    required this.debts,
    required this.isLoading,
    this.errorMessage,
    required this.addSuccess,
  });

  factory DebtState.initial() {
    return const DebtState(
      debts: [],
      isLoading: false,
      addSuccess: false,
    );
  }

  DebtState copyWith({
    List<DebtEntity>? debts,
    bool? isLoading,
    String? errorMessage,
    bool? addSuccess,
  }) {
    return DebtState(
      debts: debts ?? this.debts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      addSuccess: addSuccess ?? this.addSuccess,
    );
  }

  @override
  List<Object?> get props => [debts, isLoading, errorMessage, addSuccess];
}
