import 'package:equatable/equatable.dart';

abstract class InsightEvent extends Equatable {
  const InsightEvent();

  @override
  List<Object?> get props => [];
}

class GenerateInsightsRequested extends InsightEvent {
  final DateTime month;
  const GenerateInsightsRequested({required this.month});

  @override
  List<Object?> get props => [month];
}

class DismissInsightRequested extends InsightEvent {
  final String insightId;
  const DismissInsightRequested({required this.insightId});

  @override
  List<Object?> get props => [insightId];
}

class ClearPendingAlertRequested extends InsightEvent {
  const ClearPendingAlertRequested();
}

class ClearAllAlertsRequested extends InsightEvent {
  const ClearAllAlertsRequested();
}