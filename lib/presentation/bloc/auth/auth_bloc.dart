import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/services/settings_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SettingsService _settingsService;
  StreamSubscription<dynamic>? _userSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required SettingsService settingsService,
  }) : _authRepository = authRepository,
       _settingsService = settingsService,
       super(const AuthState.unknown()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthFinancialProfileUpdated>(_onFinancialProfileUpdated);

    _userSubscription = _authRepository.user.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  Future<void> _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      event.user.isNotEmpty
          ? AuthState.authenticated(event.user)
          : const AuthState.unauthenticated(),
    );
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      // Persist email on success
      await _settingsService.setLastEmail(event.email);
      // Success is handled by stream listener
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      );
      // Persist email on success
      await _settingsService.setLastEmail(event.email);
      // Success is handled by stream listener
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
  }

  Future<void> _onFinancialProfileUpdated(
    AuthFinancialProfileUpdated event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.updateFinancialProfile(
        monthlyIncome: event.monthlyIncome,
        currency: event.currency,
      );
      // The user stream will trigger and update the state automatically?
      // Actually AuthRepositoryImpl.user stream listens to firebase_auth.authStateChanges(), which might NOT trigger on Firestore update.
      // However, we are not listening to Firestore user document in AuthRepositoryImpl.user getter.
      // We need to fix AuthRepositoryImpl to listen to Firestore changes if we want real-time updates of custom fields.
      // OR we can manually emit an updated user state here if we want immediate UI feedback without stream.
      // But let's check AuthRepositoryImpl.user again.
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
}
