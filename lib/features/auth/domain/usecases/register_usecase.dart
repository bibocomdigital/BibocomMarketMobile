import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/core/usecase/usecase.dart';
import 'package:bibomarketmobile/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<String, RegisterParams> {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<String>> call(RegisterParams params) {
    return _repository.register(params);
  }
}
