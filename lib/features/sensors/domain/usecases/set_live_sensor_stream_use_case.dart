import 'package:tiresense/core/usecase/use_case.dart';
import 'package:tiresense/features/sensors/domain/repositories/sensor_repository.dart';

final class SetLiveSensorStreamUseCase implements UseCaseWithParam<bool, void> {
  final SensorRepository _repository;

  SetLiveSensorStreamUseCase(this._repository);

  @override
  void execute(bool enabled) {
    if (enabled) {
      _repository.startStream();
    } else {
      _repository.stopStream();
    }
  }
}
