import '../../domain/entities/debt.dart';
import '../../domain/repositories/debt_repository.dart';

class DebtRepositoryImpl implements DebtRepository {
  final List<DebtEntity> _debts = [];

  @override
  Future<List<DebtEntity>> getDebts() async {
    // Return a copy sorted by date
    final list = [..._debts];
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  @override
  Future<void> addDebt(DebtEntity debt) async {
    _debts.add(debt);
  }

  @override
  Future<void> updateDebt(DebtEntity debt) async {
    final index = _debts.indexWhere((d) => d.id == debt.id);
    if (index != -1) {
      _debts[index] = debt;
    }
  }

  @override
  Future<void> deleteDebt(String id) async {
    _debts.removeWhere((d) => d.id == id);
  }
}
