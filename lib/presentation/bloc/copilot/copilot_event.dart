import 'package:equatable/equatable.dart';

abstract class CopilotEvent extends Equatable {
  const CopilotEvent();
  @override
  List<Object?> get props => [];
}

class LoadCopilotRequested extends CopilotEvent {
  const LoadCopilotRequested();
}

class AddPlannedPurchase extends CopilotEvent {
  final String name;
  final double amount;
  final DateTime targetDate;

  const AddPlannedPurchase({
    required this.name,
    required this.amount,
    required this.targetDate,
  });

  @override
  List<Object?> get props => [name, amount, targetDate];
}

class RemovePlannedPurchase extends CopilotEvent {
  final String purchaseId;
  const RemovePlannedPurchase({required this.purchaseId});

  @override
  List<Object?> get props => [purchaseId];
}

class AcceptChallenge extends CopilotEvent {
  const AcceptChallenge();
}

class CompleteChallenge extends CopilotEvent {
  const CompleteChallenge();
}

class GenerateNewChallenge extends CopilotEvent {
  const GenerateNewChallenge();
}
