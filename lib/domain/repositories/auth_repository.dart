import '../entities/user.dart';

abstract class AuthRepository {
  Stream<UserEntity> get user;

  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> updateFinancialProfile({
    double? monthlyIncome,
    String? currency,
  });

  Future<void> updateOnyxPoints(int amount);

  Future<void> updateEmail({required String newEmail, required String password});

  Future<void> sendPasswordResetEmail(String email);
}

