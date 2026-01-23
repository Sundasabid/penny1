

import '../../models/transaction.dart';

abstract class LocalDataSource {
  Future<void> addTransaction(TransactionModel tx);
  Future<List<TransactionModel>> getTransactions();
}

/// Temporary in-memory implementation (replace with Hive later)
class InMemoryLocalDataSource implements LocalDataSource {
  final List<TransactionModel> _items = [];

  @override
  Future<void> addTransaction(TransactionModel tx) async {
    _items.add(tx);
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final list = [..._items];
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }
}
