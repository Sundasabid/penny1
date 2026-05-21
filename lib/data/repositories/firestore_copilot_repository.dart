import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/planned_purchase.dart';
import '../../domain/entities/penny_challenge.dart';
import '../../domain/repositories/copilot_repository.dart';

class FirestoreCopilotRepository implements CopilotRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? "anonymous";

  @override
  Future<List<PlannedPurchase>> getPlannedPurchases() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('planned_purchases')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PlannedPurchase(
        id: doc.id,
        name: data['name'] ?? '',
        amount: (data['amount'] as num).toDouble(),
        targetDate: (data['targetDate'] as Timestamp).toDate(),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        aiAdvice: data['aiAdvice'],
        isAiLoading: false,
      );
    }).toList();
  }

  @override
  Future<void> savePlannedPurchase(PlannedPurchase purchase) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('planned_purchases')
        .doc(purchase.id)
        .set({
      'name': purchase.name,
      'amount': purchase.amount,
      'targetDate': Timestamp.fromDate(purchase.targetDate),
      'createdAt': Timestamp.fromDate(purchase.createdAt),
      'aiAdvice': purchase.aiAdvice,
    });
  }

  @override
  Future<void> deletePlannedPurchase(String id) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('planned_purchases')
        .doc(id)
        .delete();
  }

  @override
  Future<List<PennyChallenge>> getChallenges() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('challenges')
        .orderBy('weekStart', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PennyChallenge(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        weekStart: (data['weekStart'] as Timestamp).toDate(),
        isAccepted: data['isAccepted'] ?? false,
        isCompleted: data['isCompleted'] ?? false,
        completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
        savingsAmount: (data['savingsAmount'] as num?)?.toDouble(),
      );
    }).toList();
  }

  @override
  Future<void> saveChallenge(PennyChallenge challenge) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('challenges')
        .doc(challenge.id)
        .set({
      'id': challenge.id,
      'title': challenge.title,
      'description': challenge.description,
      'weekStart': Timestamp.fromDate(challenge.weekStart),
      'isAccepted': challenge.isAccepted,
      'isCompleted': challenge.isCompleted,
      'completedAt': challenge.completedAt != null ? Timestamp.fromDate(challenge.completedAt!) : null,
      'savingsAmount': challenge.savingsAmount,
    });
  }

  @override
  Future<void> deleteChallenge(String id) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('challenges')
        .doc(id)
        .delete();
  }
}

