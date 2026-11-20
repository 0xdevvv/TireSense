sealed class Failure {
  final String message;
  
  Failure(this.message);

  @override
  bool operator ==(Object other) =>
      other is Failure &&
      other.runtimeType == runtimeType &&
      other.message == message;

  @override
  String toString() => '$runtimeType($message)';

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

final class NetworkFailure extends Failure {
  NetworkFailure([String message = 'Network request failed']) : super(message);
}

final class NotFoundFailure extends Failure {
  NotFoundFailure([String message = 'Resource not found']) : super(message);
}

final class UnknownFailure extends Failure {
  UnknownFailure([String message = 'Unexpected error']) : super(message);
}
