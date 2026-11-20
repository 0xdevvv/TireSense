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
}
