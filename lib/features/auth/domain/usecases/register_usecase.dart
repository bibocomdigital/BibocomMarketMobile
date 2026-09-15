import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/core/usecase/usecase.dart';
import 'package:bibomarketmobile/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<void, RegisterParams> {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(RegisterParams params) {
    return _repository.register(params);
  }
}
