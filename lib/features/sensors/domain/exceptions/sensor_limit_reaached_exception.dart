final class SensorLimitReachedException implements Exception {
  final String message;
  const SensorLimitReachedException(this.message);
}