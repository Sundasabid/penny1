import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../data_sources/local/local_data_source.dart';
import '../data_sources/remote/firestore_source.dart';
import '../models/receipt/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final LocalDataSource local;
  final FirestoreSource remote;

  TransactionRepositoryImpl({required this.local, required this.remote});

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await local.addTransaction(model);
    // later: await remote.addTransaction(model);
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final models = await local.getTransactions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await local.deleteTransaction(id);
  }
}
