import 'package:tiresense/core/result/failure.dart';

sealed class SerialNumberState {
  const SerialNumberState();
}

final class SerialNumberLoading extends SerialNumberState {
  const SerialNumberLoading();
}

final class SerialNumberReady extends SerialNumberState {
  final String serialNumber;

  const SerialNumberReady(this.serialNumber);
}

final class SerialNumberFailed extends SerialNumberState {
  final Failure failure;

  const SerialNumberFailed(this.failure);
}
