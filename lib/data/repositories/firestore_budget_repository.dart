import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';

class FirestoreBudgetRepository implements BudgetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<List<BudgetEntity>> getBudgets() async {
    final uid = _userId;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return BudgetEntity(
        id: doc.id,
        category: data['category'] ?? '',
        limit: (data['limit'] as num).toDouble(),
        spent: (data['spent'] as num).toDouble(),
        period: data['period'] ?? 'Monthly',
      );
    }).toList();
  }

  @override
  Future<void> saveBudget(BudgetEntity budget) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .doc(budget.id.isEmpty ? null : budget.id)
        .set({
          'category': budget.category,
          'limit': budget.limit,
          'spent': budget.spent,
          'period': budget.period,
        }, SetOptions(merge: true));
  }

  @override
  Future<void> updateSpentAmount(String category, double amount) async {
    final uid = _userId;
    if (uid == null) return;

    // Find the budget for this category
    final query = await _firestore
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .where('category', isEqualTo: category)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      await doc.reference.update({'spent': FieldValue.increment(amount)});
    }
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    final uid = _userId;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .doc(budgetId)
        .delete();
  }
}
