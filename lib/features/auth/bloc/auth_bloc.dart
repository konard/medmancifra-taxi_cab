import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';

// Events
abstract class AuthEvent {}

class AuthStarted extends AuthEvent {}

class AuthSignedIn extends AuthEvent {
  final UserModel user;
  AuthSignedIn(this.user);
}

class AuthSignedOut extends AuthEvent {}

class AuthSelectRole extends AuthEvent {
  final UserRole role;
  final String name;
  AuthSelectRole(this.role, this.name);
}

class AuthLogout extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription? _authSub;
  StreamSubscription? _userSub;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignedIn>(_onSignedIn);
    on<AuthSignedOut>(_onSignedOut);
    on<AuthSelectRole>(_onSelectRole);
    on<AuthLogout>(_onLogout);
  }

  void _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    _authSub?.cancel();
    _authSub = _authService.authStateChanges.listen((user) {
      if (user != null) {
        _userSub?.cancel();
        _userSub = _authService.watchUserProfile(user.uid).listen((userModel) {
          if (userModel != null) {
            add(AuthSignedIn(userModel));
          } else {
            add(AuthSignedOut());
          }
        });
      } else {
        add(AuthSignedOut());
      }
    });
  }

  Future<void> _onSignedIn(
    AuthSignedIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthAuthenticated(event.user));
  }

  Future<void> _onSignedOut(
    AuthSignedOut event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthUnauthenticated());
  }

  Future<void> _onSelectRole(
    AuthSelectRole event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInAnonymouslyWithRole(
        event.role,
        event.name,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await _authService.signOut();
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    _userSub?.cancel();
    return super.close();
  }
}
