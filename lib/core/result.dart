import 'package:tiresense/core/failure.dart';

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) => other is Success<T> && other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => 'Success($value)';
}

final class ErrorResult<T> extends Result<T> {
  final Failure failure;

  const ErrorResult(this.failure);

  @override
  bool operator ==(Object other) => other is ErrorResult<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'ErrorResult($failure)';
}
