import 'package:tiresense/core/usecase/use_case.dart';
import 'package:tiresense/features/sensors/domain/repositories/sensor_repository.dart';

class FindSensorUseCase implements AsyncUseCase<String> {
  final SensorRepository _repository;

  FindSensorUseCase(this._repository);

  @override
  Future<String> execute() async {
    return _repository.findSensor();
  }
}