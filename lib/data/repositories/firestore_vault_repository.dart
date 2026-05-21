import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/vault.dart';
import '../../domain/repositories/vault_repository.dart';

class FirestoreVaultRepository implements VaultRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  @override
  Future<List<VaultEntity>> getVaults() async {
    final uid = _userId;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('vaults')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return VaultEntity(
        id: doc.id,
        name: data['name'] ?? 'Vault',
        targetAmount: (data['targetAmount'] as num?)?.toDouble() ?? 0.0,
        savedAmount: (data['savedAmount'] as num?)?.toDouble() ?? 0.0,
        colorHex: data['colorHex'] ?? '0xFF2196F3',
        iconName: data['iconName'] ?? 'savings',
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> addVault(VaultEntity vault) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('vaults')
        .doc(vault.id.isEmpty ? null : vault.id)
        .set({
          'name': vault.name,
          'targetAmount': vault.targetAmount,
          'savedAmount': vault.savedAmount,
          'colorHex': vault.colorHex,
          'iconName': vault.iconName,
          'createdAt': Timestamp.fromDate(vault.createdAt),
        });
  }

  @override
  Future<void> updateVault(VaultEntity vault) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('vaults')
        .doc(vault.id)
        .update({
          'name': vault.name,
          'targetAmount': vault.targetAmount,
          'savedAmount': vault.savedAmount,
          'colorHex': vault.colorHex,
          'iconName': vault.iconName,
        });
  }

  @override
  Future<void> deleteVault(String id) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('vaults')
        .doc(id)
        .delete();
  }
}
