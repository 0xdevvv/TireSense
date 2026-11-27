import 'package:tiresense/features/sensors/domain/models/sensor_reading.dart';
import 'package:tiresense/features/sensors/presentation/states/serial_number_state.dart';

final class SensorState {
  final SensorReading reading;
  final SerialNumberState serialNumber;
  final bool isStale;

  const SensorState({
    required this.reading,
    required this.serialNumber,
    required this.isStale,
  });

  String get id => reading.id;

  SensorState copyWith({
    SensorReading? reading,
    SerialNumberState? serialNumber,
    bool? isStale,
  }) {
    return SensorState(
      reading: reading ?? this.reading,
      serialNumber: serialNumber ?? this.serialNumber,
      isStale: isStale ?? this.isStale,
    );
  }
}
