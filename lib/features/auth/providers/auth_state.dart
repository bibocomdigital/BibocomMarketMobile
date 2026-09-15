import 'package:bibomarketmobile/core/error/failures.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/auth_session.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/user.dart';

class AuthState {
  const AuthState({
    this.session,
    this.isRestoring = false,
    this.isLoading = false,
    this.failure,
  });

  final AuthSession? session;
  final bool isRestoring;
  final bool isLoading;
  final Failure? failure;

  bool get isAuthenticated => session != null;
  User? get user => session?.user;

  AuthState copyWith({
    AuthSession? session,
    bool clearSession = false,
    bool? isRestoring,
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return AuthState(
      session: clearSession ? null : (session ?? this.session),
      isRestoring: isRestoring ?? this.isRestoring,
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}
