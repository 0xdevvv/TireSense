import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';
import 'package:tiresense/features/sensors/presentation/states/sensor_state.dart';
import 'package:tiresense/features/sensors/presentation/states/serial_number_state.dart';

final class SensorsState {
  final Map<String, SensorState> _sensors;
  final List<String> _sensorIds;
  final DateTime? _lastUpdated;

  const SensorsState({
    this._sensors = const {}, 
    this._sensorIds = const [], 
    this._lastUpdated
  });

  List<String> get sensorIds => _sensorIds;
  DateTime? get lastUpdated => _lastUpdated;
  SensorState? sensor(String sensorId) => _sensors[sensorId];

  ({SensorsState state, List<String> pendingSerialNumbers}) applyFrame(SensorFrame frame) {
    final arrived = {for (final reading in frame.readings) reading.id: reading};
    final sensors = Map<String, SensorState>.of(_sensors);
    final pendingSerialNumbers = <String>[];

    for (final id in {...sensors.keys, ...arrived.keys}) {
      final newReading = arrived[id];
      final currentSensor = sensors[id];
      final isNew = currentSensor == null;

      sensors[id] = SensorState(
        reading: isNew ? newReading! : currentSensor.reading,
        serialNumber: isNew ? const SerialNumberLoading() : currentSensor.serialNumber,
        isStale: newReading == null,
      );
      
      if (isNew) {
        pendingSerialNumbers.add(id);
      }
    }

    return (
      state: SensorsState(
        sensors: sensors,
        sensorIds: _getSensorIds(sensors),
        lastUpdated: frame.timestamp,
      ),
      pendingSerialNumbers: pendingSerialNumbers,
    );
  }

  List<String> _getSensorIds(Map<String, SensorState> sensors) {
    if (sensors.length == _sensorIds.length && _sensorIds.every(sensors.containsKey)) {
      return _sensorIds;
    }
    
    return sensors.keys.toList()..sort();
  }

  SensorsState updateSerialNumber(
    String sensorId,
    SerialNumberState serialNumber,
  ) {
    final current = _sensors[sensorId];
    
    if (current == null) {
      return this;
    }

    final sensors = Map<String, SensorState>.of(_sensors);
    sensors[sensorId] = current.copyWith(serialNumber: serialNumber);
    
    return SensorsState(
      sensors: sensors,
      sensorIds: _sensorIds,
      lastUpdated: _lastUpdated,
    );
  }
}
