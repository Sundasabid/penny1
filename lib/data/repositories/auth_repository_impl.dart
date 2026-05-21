import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl();

  firebase_auth.FirebaseAuth get _auth => firebase_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  Stream<UserEntity> get user {
    return _auth.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) {
        return Stream.value(UserEntity.empty);
      }
      return _firestore.collection('users').doc(firebaseUser.uid).snapshots().map((snapshot) {
        if (!snapshot.exists) {
          // Fallback if document doesn't exist yet
          return UserEntity(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName,
            phoneNumber: firebaseUser.phoneNumber,
            photoUrl: firebaseUser.photoURL,
          );
        }
        final data = snapshot.data()!;
        final preferences = data['preferences'] as Map<String, dynamic>?;
        
        return UserEntity(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: data['displayName'] as String? ?? firebaseUser.displayName,
          phoneNumber: firebaseUser.phoneNumber,
          photoUrl: data['photoUrl'] as String? ?? firebaseUser.photoURL,
          monthlyIncome: (data['monthlyIncome'] as num?)?.toDouble(),
          currency: preferences?['currency'] as String?,
          onyxPoints: data['onyxPoints'] as int? ?? 0,
        );
      });
    });
  }


  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // 1. Create Auth User
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user!;

      // 2. Create User Entity
      final userEntity = UserEntity(
        id: firebaseUser.uid,
        email: email,
        displayName: fullName,
      );

      // 3. Update Display Name in Auth (Best Practice)
      try {
        await firebaseUser.updateDisplayName(fullName);
      } catch (_) {
        // Non-critical
      }

      // 4. Create User Document in Firestore with Enhanced Metadata
      try {
        await _firestore.collection('users').doc(userEntity.id).set({
          'email': userEntity.email,
          'displayName': userEntity.displayName,
          'photoUrl': null, // Placeholder for future profile picture
          'onyxPoints': 0, // Initialize virtual rewards
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'preferences': {
            'currency': 'USD',
            'theme': 'light',
            'notifications': true,
          },
        });

        debugPrint('✅ User document created in Firestore: ${userEntity.id}');
      } catch (e) {
        // Log error but DO NOT fail the signup. User is already created in Auth.
        // In a production app, you might implement a retry mechanism or background sync.
        debugPrint('⚠️ Firestore User Document Write Failed: $e');
        debugPrint(
          '   User ${userEntity.id} created in Auth but not in Firestore.',
        );
        debugPrint('   Consider implementing a background sync mechanism.');
      }

      return userEntity;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // 5. Friendly Error Messages
      String message = "An error occurred during signup";
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        // Fallback: Show the actual error so we can fix it
        message = "${e.message} (Code: ${e.code})";
      }
      throw Exception(message);
    } catch (e) {
      throw Exception("Signup failed: ${e.toString()}");
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      debugPrint('🔐 signIn attempt for: $email');
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint('✅ signIn succeeded for: $email');
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException code="${e.code}" message="${e.message}"');
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found for that email. Please sign up first.';
          break;
        case 'wrong-password':
          message = 'Wrong password. Please try again.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'invalid-credential':
          message =
              'Invalid email or password. If you signed up with Google, use the Google option instead.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please wait a moment and try again.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your internet connection.';
          break;
        case 'operation-not-allowed':
          message =
              'Email/password sign-in is disabled for this project. Enable it in the Firebase Console.';
          break;
        default:
          message = 'Login failed (${e.code}): ${e.message ?? 'Unknown error'}';
      }
      throw Exception(message);
    } catch (e) {
      debugPrint('❌ signIn unexpected error: $e');
      throw Exception("Login failed: ${e.toString()}");
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Update user profile information in Firestore
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) {
        updates['displayName'] = displayName;
        // Also update in Firebase Auth
        await user.updateDisplayName(displayName);
      }

      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
        // Also update in Firebase Auth
        await user.updatePhotoURL(photoUrl);
      }

      await _firestore.collection('users').doc(user.uid).update(updates);
      debugPrint('✅ User profile updated for: ${user.uid}');
    } catch (e) {
      debugPrint('⚠️ Profile update failed: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> updateFinancialProfile({
    double? monthlyIncome,
    String? currency,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (monthlyIncome != null) {
        updates['monthlyIncome'] = monthlyIncome;
      }

      if (currency != null) {
        updates['preferences.currency'] = currency;
      }

      await _firestore.collection('users').doc(user.uid).update(updates);
      debugPrint('✅ Financial profile updated for: ${user.uid}');
    } catch (e) {
      debugPrint('⚠️ Financial profile update failed: $e');
      throw Exception('Failed to update financial profile: $e');
    }
  }

  @override
  Future<void> updateOnyxPoints(int amount) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'onyxPoints': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Onyx points updated by $amount for: ${user.uid}');
    } catch (e) {
      debugPrint('⚠️ Onyx points update failed: $e');
    }
  }

  @override
  Future<void> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      // 1. RE-AUTHENTICATION (Required for sensitive changes)
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // 2. TRIGGER VERIFICATION LINK
      // This sends a link to the NEW email. Once verified, Firebase updates it.
      await user.verifyBeforeUpdateEmail(newEmail);

      debugPrint('✅ Verification link sent to $newEmail');
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = "Security verification failed";
      if (e.code == 'wrong-password') {
        message = 'The current password you entered is incorrect.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The new email address is already in use by another account.';
      } else if (e.code == 'invalid-email') {
        message = 'The new email address is not valid.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Security timeout. Please log out and back in to change your email.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to trigger email update: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset link sent to $email');
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message = "Security error";
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }
}

