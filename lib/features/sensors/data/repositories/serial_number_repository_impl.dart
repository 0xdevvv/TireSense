import 'package:tiresense/core/network/http_status_exception.dart';
import 'package:tiresense/core/result/failure.dart';
import 'package:tiresense/core/result/result.dart';
import 'package:tiresense/features/sensors/data/datasources/sensor/api/sensor_api.dart';
import 'package:tiresense/features/sensors/domain/repositories/serial_number_repository.dart';

final class SerialNumberRepositoryImpl implements SerialNumberRepository {
  final SensorApi _api;

  SerialNumberRepositoryImpl(this._api);

  @override
  Future<Result<String>> getSerialNumber(String sensorId) async {
    try {
      final dto = await _api.getSerialNumber(sensorId);
      return Success(dto.serialNumber);
    } on HttpStatusException catch (error) {
      if (error.statusCode == 404) {
        return ErrorResult(NotFoundFailure());
      }
      return ErrorResult(NetworkFailure());
    } on FormatException {
      return ErrorResult(UnknownFailure());
    } on Exception {
      return ErrorResult(UnknownFailure());
    }
  }
}
