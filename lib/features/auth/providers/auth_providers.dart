import 'package:bibomarketmobile/core/auth/google_auth_service.dart';
import 'package:bibomarketmobile/core/error/error_mapper.dart';
import 'package:bibomarketmobile/core/providers/core_providers.dart';
import 'package:bibomarketmobile/core/usecase/usecase.dart';
import 'package:bibomarketmobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bibomarketmobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bibomarketmobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bibomarketmobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:bibomarketmobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:bibomarketmobile/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:bibomarketmobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bibomarketmobile/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(
    tokenStorage: ref.watch(tokenStorageProvider),
    localStorage: ref.watch(localStorageServiceProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final loginWithGoogleUseCaseProvider = Provider<LoginWithGoogleUseCase>((ref) {
  return LoginWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>((ref) {
  return RestoreSessionUseCase(ref.watch(authRepositoryProvider));
});

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(restoreSession);
    return const AuthState(isRestoring: true);
  }

  Future<void> restoreSession() async {
    final result =
        await ref.read(restoreSessionUseCaseProvider).call(const NoParams());
    state = result.fold(
      failure: (failure) => AuthState(isRestoring: false, failure: failure),
      success: (session) => AuthState(session: session, isRestoring: false),
    );
  }

  Future<bool> login(LoginParams params) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await ref.read(loginUseCaseProvider).call(params);
    return result.fold(
      failure: (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
        return false;
      },
      success: (session) {
        state = AuthState(session: session);
        return true;
      },
    );
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      final google = await ref.read(googleAuthServiceProvider).signIn();
      if (google == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }
      final result =
          await ref.read(loginWithGoogleUseCaseProvider).call(google.idToken);
      return result.fold(
        failure: (failure) {
          state = state.copyWith(isLoading: false, failure: failure);
          return false;
        },
        success: (session) {
          state = AuthState(session: session);
          return true;
        },
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        failure: ErrorMapper.map(error),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call(const NoParams());
    state = const AuthState();
  }
}
