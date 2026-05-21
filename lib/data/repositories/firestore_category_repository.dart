import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';

class FirestoreCategoryRepository implements CategoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreCategoryRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference get _categoriesCollection {
    if (_userId.isEmpty) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(_userId).collection('categories');
  }

  @override
  Stream<List<CategoryEntity>> getCategories() async* {
    if (_userId.isEmpty) {
      yield [];
      return;
    }

    try {
      // Check if categories exist, if not seed defaults
      final snapshot = await _categoriesCollection.limit(1).get();
      if (snapshot.docs.isEmpty) {
        await _seedDefaultCategories();
      }
    } catch (e) {
      // Ignore error and proceed to stream
    }

    yield* _categoriesCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromSnapshot(doc))
          .toList();
    });
  }

  Future<void> _seedDefaultCategories() async {
    final batch = _firestore.batch();
    for (final category in CategoryEntity.defaultCategories) {
      final docRef = _categoriesCollection.doc(); // Generate new ID
      // Or use defined IDs from entity if we want strict control
      final data = CategoryModel.fromEntity(category).toDocument();
      // remove id from data if it was part of it, but model toDocument doesn't include ID
      batch.set(docRef, data);
    }
    await batch.commit();
  }

  @override
  Future<void> addCategory(CategoryEntity category) async {
    await _categoriesCollection.add(
      CategoryModel.fromEntity(category).toDocument(),
    );
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    await _categoriesCollection
        .doc(category.id)
        .update(CategoryModel.fromEntity(category).toDocument());
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _categoriesCollection.doc(id).delete();
  }

  @override
  Future<void> resetToDefaults() async {
    final snapshot = await _categoriesCollection.get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    await _seedDefaultCategories();
  }
}
