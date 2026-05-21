import 'package:equatable/equatable.dart';
import '../../../domain/entities/planned_purchase.dart';
import '../../../domain/entities/penny_challenge.dart';

abstract class CopilotState extends Equatable {
  const CopilotState();
  @override
  List<Object?> get props => [];
}

class CopilotInitial extends CopilotState {}

class CopilotLoading extends CopilotState {}

class CopilotLoaded extends CopilotState {
  final int healthScore; // 0-100
  final List<PlannedPurchase> purchases;
  final List<PennyChallenge> challenges;
  final PennyChallenge? activeChallenge;
  final bool isChallengeLoading;
  final List<DetectedSubscription> subscriptions;
  final double totalFixedCosts;
  // Forecast data
  final List<double> actualDailySpend; // Day-by-day spend this month
  final double projectedMonthEnd;

  const CopilotLoaded({
    required this.healthScore,
    this.purchases = const [],
    this.challenges = const [],
    this.activeChallenge,
    this.isChallengeLoading = false,
    this.subscriptions = const [],
    this.totalFixedCosts = 0,
    this.actualDailySpend = const [],
    this.projectedMonthEnd = 0,
  });

  CopilotLoaded copyWith({
    int? healthScore,
    List<PlannedPurchase>? purchases,
    List<PennyChallenge>? challenges,
    PennyChallenge? activeChallenge,
    bool? isChallengeLoading,
    bool clearChallenge = false,
    List<DetectedSubscription>? subscriptions,
    double? totalFixedCosts,
    List<double>? actualDailySpend,
    double? projectedMonthEnd,
  }) {
    return CopilotLoaded(
      healthScore: healthScore ?? this.healthScore,
      purchases: purchases ?? this.purchases,
      challenges: challenges ?? this.challenges,
      activeChallenge: clearChallenge ? null : (activeChallenge ?? this.activeChallenge),
      isChallengeLoading: isChallengeLoading ?? this.isChallengeLoading,
      subscriptions: subscriptions ?? this.subscriptions,
      totalFixedCosts: totalFixedCosts ?? this.totalFixedCosts,
      actualDailySpend: actualDailySpend ?? this.actualDailySpend,
      projectedMonthEnd: projectedMonthEnd ?? this.projectedMonthEnd,
    );
  }

  @override
  List<Object?> get props => [
    healthScore, purchases, challenges, activeChallenge, isChallengeLoading,
    subscriptions, totalFixedCosts, actualDailySpend, projectedMonthEnd,
  ];
}


class CopilotError extends CopilotState {
  final String message;
  const CopilotError(this.message);

  @override
  List<Object?> get props => [message];
}

/// A detected recurring expense
class DetectedSubscription extends Equatable {
  final String merchant;
  final double avgAmount;
  final int occurrences;

  const DetectedSubscription({
    required this.merchant,
    required this.avgAmount,
    required this.occurrences,
  });

  @override
  List<Object?> get props => [merchant, avgAmount, occurrences];
}
