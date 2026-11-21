import 'package:tiresense/features/sensors/domain/models/sensor_reading.dart';
import 'package:tiresense/features/sensors/presentation/states/serial_number_state.dart';

final class SensorsState {
  final Map<String, SensorReading> readings;
  final Map<String, SerialNumberState> serialNumbers;
  final Set<String> staleSensorIds;
  final DateTime? lastUpdated;

  const SensorsState({
    this.readings = const {},
    this.serialNumbers = const {},
    this.staleSensorIds = const {},
    this.lastUpdated,
  });

  SensorsState copyWith({
    Map<String, SensorReading>? readings,
    Map<String, SerialNumberState>? serialNumbers,
    Set<String>? staleSensorIds,
    DateTime? lastUpdated,
  }) {
    return SensorsState(
      readings: readings ?? this.readings,
      serialNumbers: serialNumbers ?? this.serialNumbers,
      staleSensorIds: staleSensorIds ?? this.staleSensorIds,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  SensorsState updateSerialNumber(
    String sensorId,
    SerialNumberState serialNumber,
  ) {
    final updated = Map<String, SerialNumberState>.of(serialNumbers);
    updated[sensorId] = serialNumber;
    return copyWith(serialNumbers: updated);
  }
}
