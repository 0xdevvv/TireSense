import 'package:tiresense/core/usecase/use_case.dart';
import 'package:tiresense/features/sensors/domain/repositories/sensor_repository.dart';

final class RequestSensorFrameUseCase implements AsyncUseCase<void> {
  final SensorRepository _repository;

  RequestSensorFrameUseCase(this._repository);

  @override
  Future<void> execute() => _repository.requestFrame();
}
