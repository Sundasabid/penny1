import 'package:equatable/equatable.dart';
import '../../../domain/entities/insight.dart';

abstract class InsightState extends Equatable {
  const InsightState();

  @override
  List<Object?> get props => [];
}

class InsightInitial extends InsightState {}

class InsightLoading extends InsightState {}

class InsightLoaded extends InsightState {
  final List<InsightEntity> insights;
  final String? aiCoachNote;
  final String? dailyTip;
  final String? dynamicNarrative;
  final bool isAiLoading;
  
  /// The specific insight that should trigger a global popup alert
  final InsightEntity? pendingAlert;
  
  /// IDs of insights that the user has manually dismissed
  final Set<String> dismissedIds;

  const InsightLoaded({
    required this.insights,
    this.aiCoachNote,
    this.dailyTip,
    this.dynamicNarrative,
    this.isAiLoading = false,
    this.pendingAlert,
    this.dismissedIds = const {},
  });

  /// Returns only insights that aren't dismissed
  List<InsightEntity> get visibleInsights => 
      insights.where((i) => !dismissedIds.contains(i.id)).toList();

  @override
  List<Object?> get props => [
    insights, aiCoachNote, dailyTip, dynamicNarrative, isAiLoading, pendingAlert, dismissedIds
  ];

  InsightLoaded copyWith({
    List<InsightEntity>? insights,
    String? aiCoachNote,
    String? dailyTip,
    String? dynamicNarrative,
    bool? isAiLoading,
    InsightEntity? pendingAlert,
    bool clearPendingAlert = false,
    Set<String>? dismissedIds,
  }) {
    return InsightLoaded(
      insights: insights ?? this.insights,
      aiCoachNote: aiCoachNote ?? this.aiCoachNote,
      dailyTip: dailyTip ?? this.dailyTip,
      dynamicNarrative: dynamicNarrative ?? this.dynamicNarrative,
      isAiLoading: isAiLoading ?? this.isAiLoading,
      pendingAlert: clearPendingAlert ? null : (pendingAlert ?? this.pendingAlert),
      dismissedIds: dismissedIds ?? this.dismissedIds,
    );
  }
}

class InsightError extends InsightState {
  final String message;
  const InsightError(this.message);

  @override
  List<Object?> get props => [message];
}
