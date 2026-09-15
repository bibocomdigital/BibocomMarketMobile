import 'package:bibomarketmobile/core/result/result.dart';
import 'package:bibomarketmobile/core/usecase/usecase.dart';
import 'package:bibomarketmobile/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams params) => _repository.logout();
}
