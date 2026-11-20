import 'package:tiresense/features/sensors/domain/models/sensor_reading.dart';

final class SensorFrame {
  final DateTime timestamp;
  final List<SensorReading> readings;

  SensorFrame({required this.timestamp, required List<SensorReading> readings})
    : readings = List.unmodifiable(readings);

  @override
  bool operator ==(Object other) {
    if (other is! SensorFrame || other.timestamp != timestamp) {
      return false;
    }
    if (other.readings.length != readings.length) {
      return false;
    }
    for (var i = 0; i < readings.length; i++) {
      if (other.readings[i] != readings[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(timestamp, Object.hashAll(readings));

  @override
  String toString() => 'SensorFrame($timestamp, ${readings.length} readings)';
}
