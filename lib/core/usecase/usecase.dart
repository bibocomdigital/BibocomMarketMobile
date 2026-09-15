import 'package:bibomarketmobile/core/result/result.dart';

abstract class UseCase<Output, Input> {
  Future<Result<Output>> call(Input params);
}

final class NoParams {
  const NoParams();
}
