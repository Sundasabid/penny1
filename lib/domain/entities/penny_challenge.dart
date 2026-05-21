import 'package:equatable/equatable.dart';

class PennyChallenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime weekStart;
  final bool isAccepted;
  final bool isCompleted;
  final DateTime? completedAt;
  final double? savingsAmount;

  const PennyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.weekStart,
    this.isAccepted = false,
    this.isCompleted = false,
    this.completedAt,
    this.savingsAmount,
  });

  PennyChallenge copyWith({
    bool? isAccepted,
    bool? isCompleted,
    DateTime? completedAt,
    double? savingsAmount,
  }) {
    return PennyChallenge(
      id: id,
      title: title,
      description: description,
      weekStart: weekStart,
      isAccepted: isAccepted ?? this.isAccepted,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      savingsAmount: savingsAmount ?? this.savingsAmount,
    );
  }

  @override
  List<Object?> get props => [id, title, description, weekStart, isAccepted, isCompleted, completedAt, savingsAmount];
}

