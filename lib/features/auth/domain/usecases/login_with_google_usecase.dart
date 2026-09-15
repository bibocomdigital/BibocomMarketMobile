import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/core/usecase/usecase.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/auth_session.dart';
import 'package:bibomarketmobile/features/auth/domain/repositories/auth_repository.dart';

class LoginWithGoogleUseCase implements UseCase<AuthSession, String> {
  LoginWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthSession>> call(String idToken) {
    return _repository.loginWithGoogle(idToken);
  }
}
