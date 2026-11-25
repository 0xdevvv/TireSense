import 'package:tiresense/core/usecase/use_case.dart';
import 'package:tiresense/features/sensors/domain/repositories/sensor_repository.dart';

final class AddSensorUseCase implements UseCaseWithParam<String, void> {
  final SensorRepository _repository;

  AddSensorUseCase(this._repository);

  @override
  void execute(String sensorId) {
    _repository.addSensor(sensorId);
  }
}