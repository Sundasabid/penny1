import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity user;
  final String? errorMessage;

  const AuthState._({
    this.status = AuthStatus.unknown,
    this.user = UserEntity.empty,
    this.errorMessage,
  });

  const AuthState.unknown() : this._();

  const AuthState.authenticated(UserEntity user)
    : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);

  const AuthState.loading() : this._(status: AuthStatus.loading);

  const AuthState.error(String message)
    : this._(status: AuthStatus.error, errorMessage: message);

  @override
  List<Object?> get props => [status, user, errorMessage];
}
