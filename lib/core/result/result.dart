import 'package:bibomarketmobile/core/error/failures.dart';

sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(Failure failure) failure,
    required R Function(T data) success,
  });

  bool get isSuccess => this is Success<T>;
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;

  @override
  R fold<R>({
    required R Function(Failure failure) failure,
    required R Function(T data) success,
  }) =>
      success(data);
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;

  @override
  R fold<R>({
    required R Function(Failure failure) failure,
    required R Function(T data) success,
  }) =>
      failure(this.failure);
}
