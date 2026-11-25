import 'package:tiresense/features/sensors/data/datasources/ble/api/ble_sensor_data_source.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';
import 'package:tiresense/features/sensors/domain/repositories/sensor_repository.dart';

final class SensorRepositoryImpl implements SensorRepository {
  final BleSensorDataSource _dataSource;

  SensorRepositoryImpl(this._dataSource);

  @override
  Stream<SensorFrame> watchFrames() => _dataSource.frames();

  @override
  Future<void> requestFrame() => _dataSource.requestFrame();

  @override
  void startStream() => _dataSource.startStream();

  @override
  void stopStream() => _dataSource.stopStream();

  @override
  void addSensor(String sensorId) => _dataSource.addSensor(sensorId);

  @override
  Future<String> findSensor() => _dataSource.findSensor();
}
