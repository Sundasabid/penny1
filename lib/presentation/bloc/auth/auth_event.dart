import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final UserEntity user;
  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;

  const AuthSignupRequested({
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthFinancialProfileUpdated extends AuthEvent {
  final double? monthlyIncome;
  final String? currency;

  const AuthFinancialProfileUpdated({this.monthlyIncome, this.currency});

  @override
  List<Object?> get props => [monthlyIncome, currency];
}
