import 'package:tiresense/core/result/result.dart';
import 'package:tiresense/core/usecase/use_case.dart';
import 'package:tiresense/features/sensors/domain/repositories/serial_number_repository.dart';

final class GetSerialNumberUseCase implements AsyncUseCaseWithParam<String, Result<String>> {
  final SerialNumberRepository _repository;

  GetSerialNumberUseCase(this._repository);

  @override
  Future<Result<String>> execute(String sensorId) {
    return _repository.getSerialNumber(sensorId);
  }
}
