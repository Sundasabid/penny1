import '../../domain/entities/budget.dart';

abstract class BudgetRepository {
  Future<List<BudgetEntity>> getBudgets();
  Future<void> saveBudget(BudgetEntity budget);
  Future<void> updateSpentAmount(String category, double amount);
  Future<void> deleteBudget(String budgetId);
}
