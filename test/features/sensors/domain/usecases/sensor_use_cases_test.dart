import 'package:flutter_test/flutter_test.dart';
import 'package:tiresense/core/result/result.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_reading.dart';
import 'package:tiresense/features/sensors/domain/repositories/sensor_repository.dart';
import 'package:tiresense/features/sensors/domain/repositories/serial_number_repository.dart';
import 'package:tiresense/features/sensors/domain/usecases/get_serial_number_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/request_sensor_frame_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/watch_sensor_frames_use_case.dart';

void main() {
  group('sensor use cases', () {
    test('GetSerialNumberUseCase returns the repository result', () async {
      final repository = _FakeSerialNumberRepository(Success('SN-2026-0001'));
      final useCase = GetSerialNumberUseCase(repository);

      final result = await useCase.execute('SENSOR_001');

      expect(repository.sensorId, 'SENSOR_001');
      expect(result, Success<String>('SN-2026-0001'));
    });

    test('RequestSensorFrameUseCase asks the repository for a frame', () async {
      final repository = _FakeSensorRepository();
      final useCase = RequestSensorFrameUseCase(repository);

      await useCase.execute();

      expect(repository.requests, 1);
    });

    test('WatchSensorFramesUseCase exposes the repository stream', () async {
      final repository = _FakeSensorRepository();
      final useCase = WatchSensorFramesUseCase(repository);

      final frame = await useCase.execute().first;

      expect(frame.readings.single.id, 'SENSOR_001');
    });
  });
}

final class _FakeSerialNumberRepository implements SerialNumberRepository {
  final Result<String> result;
  String? sensorId;

  _FakeSerialNumberRepository(this.result);

  @override
  Future<Result<String>> getSerialNumber(String sensorId) async {
    this.sensorId = sensorId;
    return result;
  }
}

final class _FakeSensorRepository implements SensorRepository {
  int requests = 0;

  @override
  Stream<SensorFrame> watchFrames() async* {
    yield SensorFrame(
      timestamp: DateTime.utc(2026, 1, 1),
      readings: [
        SensorReading(
          id: 'SENSOR_001',
          pressure: 2.2,
          temperature: 20,
          rssi: -60,
          batteryLevel: 80,
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      ],
    );
  }

  @override
  Future<void> requestFrame() async {
    requests++;
  }

  @override
  @override
  Future<String> findSensor() async => 'SENSOR_005';

  @override
  void addSensor(String sensorId) {}

  @override
  void startStream() {}

  @override
  void stopStream() {}
}
