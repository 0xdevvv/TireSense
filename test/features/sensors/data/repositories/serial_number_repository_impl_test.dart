import 'package:flutter_test/flutter_test.dart';
import 'package:tiresense/core/network/http_status_exception.dart';
import 'package:tiresense/core/result/failure.dart';
import 'package:tiresense/core/result/result.dart';
import 'package:tiresense/features/sensors/data/datasources/sensor/api/sensor_api.dart';
import 'package:tiresense/features/sensors/data/dto/serial_number_dto.dart';
import 'package:tiresense/features/sensors/data/repositories/serial_number_repository_impl.dart';

void main() {
  group('SerialNumberRepositoryImpl', () {
    test('returns the serial number', () async {
      final repository = SerialNumberRepositoryImpl(
        _FakeSensorApi(
          SerialNumberDto(sensorId: 'SENSOR_001', serialNumber: 'SN-2026-0001'),
        ),
      );

      final result = await repository.getSerialNumber('SENSOR_001');

      expect(result, Success<String>('SN-2026-0001'));
    });

    test('maps HTTP 404 to NotFoundFailure', () async {
      final repository = SerialNumberRepositoryImpl(
        _FakeSensorApi.httpStatus(404),
      );

      final result = await repository.getSerialNumber('SENSOR_999');

      expect(result, ErrorResult<String>(NotFoundFailure()));
    });

    test('maps HTTP 503 to NetworkFailure', () async {
      final repository = SerialNumberRepositoryImpl(
        _FakeSensorApi.httpStatus(503),
      );

      final result = await repository.getSerialNumber('SENSOR_001');

      expect(result, ErrorResult<String>(NetworkFailure()));
    });

    test('maps a bad payload to UnknownFailure', () async {
      final repository = SerialNumberRepositoryImpl(
        _FakeSensorApi.error(
          const FormatException('Invalid serial number payload.'),
        ),
      );

      final result = await repository.getSerialNumber('SENSOR_001');

      expect(result, ErrorResult<String>(UnknownFailure()));
    });
  });
}

final class _FakeSensorApi implements SensorApi {
  final SerialNumberDto? dto;
  final Object? error;
  final int? statusCode;

  _FakeSensorApi(this.dto) : error = null, statusCode = null;

  _FakeSensorApi.httpStatus(this.statusCode) : dto = null, error = null;

  _FakeSensorApi.error(this.error) : dto = null, statusCode = null;

  @override
  Future<SerialNumberDto> getSerialNumber(String sensorId) async {
    final status = statusCode;
    if (status != null) {
      throw HttpStatusException(status, '/api/sensors/$sensorId/serial-number');
    }
    final thrown = error;
    if (thrown != null) {
      throw thrown;
    }
    return dto!;
  }
}
