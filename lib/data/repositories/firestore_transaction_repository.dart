import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class FirestoreTransactionRepository implements TransactionRepository {
  FirestoreTransactionRepository();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    debugPrint("🔥 Firestore Writing Transaction: ${transaction.id} | Merchant: ${transaction.merchant}");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(transaction.id)
        .set({
          'id': transaction.id,
          'merchant': transaction.merchant,
          'amount': transaction.amount,
          'date': Timestamp.fromDate(transaction.dateTime),
          'isIncome': transaction.isIncome,
          'category': transaction.category,
          'paymentMethod': transaction.paymentMethod,
          'source': transaction.source.toString(),
          'receiptId': transaction.receiptId,
        });
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return TransactionEntity(
        id: data['id'],
        merchant: data['merchant'] ?? 'Unknown',
        amount: (data['amount'] as num).toDouble(),
        dateTime: (data['date'] as Timestamp).toDate(),
        isIncome: data['isIncome'] ?? false,
        category: data['category'] ?? 'General',
        paymentMethod: data['paymentMethod'] ?? 'Cash',
        source: _parseSource(data['source']),
        receiptId: data['receiptId'],
      );
    }).toList();
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .doc(id)
        .delete();
  }

  TransactionSource _parseSource(String? source) {
    if (source == 'TransactionSource.receipt') {
      return TransactionSource.receipt;
    } else if (source == 'TransactionSource.sms') {
      return TransactionSource.sms;
    }
    return TransactionSource.manual;
  }
}
