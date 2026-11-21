import 'package:tiresense/core/usecase/use_case.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';
import 'package:tiresense/features/sensors/domain/repositories/sensor_repository.dart';

final class WatchSensorFramesUseCase implements StreamUseCase<SensorFrame> {
  final SensorRepository _repository;

  WatchSensorFramesUseCase(this._repository);

  @override
  Stream<SensorFrame> execute() => _repository.watchFrames();
}
