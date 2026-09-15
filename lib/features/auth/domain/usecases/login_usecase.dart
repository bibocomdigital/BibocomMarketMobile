import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/core/usecase/usecase.dart';
import 'package:bibomarketmobile/features/auth/domain/entities/auth_session.dart';
import 'package:bibomarketmobile/features/auth/domain/repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({
    this.email,
    this.phoneNumber,
    required this.password,
  });

  final String? email;
  final String? phoneNumber;
  final String password;
}

class LoginUseCase implements UseCase<AuthSession, LoginParams> {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthSession>> call(LoginParams params) {
    return _repository.login(
      email: params.email,
      phoneNumber: params.phoneNumber,
      password: params.password,
    );
  }
}
