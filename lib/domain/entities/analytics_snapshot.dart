import 'package:equatable/equatable.dart';

class AnalyticsSnapshot extends Equatable {
  final DateTime month;
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> categoryExpenses;
  final int transactionCount;

  const AnalyticsSnapshot({
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.categoryExpenses,
    required this.transactionCount,
  });

  double get savingsRate {
    if (totalIncome <= 0) return 0;
    return ((totalIncome - totalExpense) / totalIncome) * 100;
  }

  @override
  List<Object?> get props => [month, totalIncome, totalExpense, categoryExpenses, transactionCount];
}
