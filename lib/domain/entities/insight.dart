import 'package:equatable/equatable.dart';

enum InsightType { velocity, anomaly, trend, tip, projection }
enum InsightImpact { positive, warning, neutral }
enum InsightPriority { low, medium, high }
enum InsightActionType { setBudget, viewHistory, dailyTip, none }

class InsightEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final InsightImpact impact;
  final DateTime createdAt;
  final InsightPriority priority;
  final InsightActionType actionType;
  
  /// Category related to this insight (optional)
  final String? category;
  
  /// Key-value pairs for specific data points (e.g., {"percentage": "25", "amount": "5000"})
  final Map<String, dynamic> metadata;

  const InsightEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.impact,
    required this.createdAt,
    this.priority = InsightPriority.low,
    this.actionType = InsightActionType.none,
    this.category,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
    id, title, description, type, impact, createdAt, priority, actionType, category, metadata
  ];

  InsightEntity copyWith({
    String? id,
    String? title,
    String? description,
    InsightType? type,
    InsightImpact? impact,
    DateTime? createdAt,
    InsightPriority? priority,
    InsightActionType? actionType,
    String? category,
    Map<String, dynamic>? metadata,
  }) {
    return InsightEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      impact: impact ?? this.impact,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      actionType: actionType ?? this.actionType,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
    );
  }
}
