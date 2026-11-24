import 'package:tiresense/core/usecase/use_case.dart';
import 'package:tiresense/features/sensors/domain/exceptions/sensor_limit_reaached_exception.dart';
import 'package:tiresense/features/sensors/domain/repositories/sensor_repository.dart';

final class AddSensorUseCase implements UseCaseWithParam<String, void> {
  static const _sensorLimit = 7;
  
  final SensorRepository _repository;

  AddSensorUseCase(this._repository);

  @override
  void execute(String sensorId) {
    if (_repository.sensorCount >= _sensorLimit) {
      throw SensorLimitReachedException('Sensor limit reached');
    }

    _repository.addSensor(sensorId);
  }
}