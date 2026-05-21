import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';

class FirestoreSubscriptionRepository implements SubscriptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<void> addSubscription(SubscriptionEntity subscription) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not logged in');

    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('subscriptions')
        .doc(subscription.id.isEmpty ? _uuid.v4() : subscription.id);

    final finalSub = subscription.copyWith(id: docRef.id);
    await docRef.set(finalSub.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteSubscription(String id) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('subscriptions')
        .doc(id)
        .delete();
  }

  @override
  Future<List<SubscriptionEntity>> getSubscriptions() async {
    final uid = _userId;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('subscriptions')
        .get();

    return snapshot.docs.map((doc) {
      return SubscriptionEntity.fromMap(doc.data(), doc.id);
    }).toList();
  }

  @override
  Future<void> updateSubscription(SubscriptionEntity subscription) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('subscriptions')
        .doc(subscription.id)
        .set(subscription.toMap(), SetOptions(merge: true));
  }
}
