import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiresense/core/result/failure.dart';
import 'package:tiresense/core/result/result.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_reading.dart';
import 'package:tiresense/features/sensors/domain/repositories/sensor_repository.dart';
import 'package:tiresense/features/sensors/domain/repositories/serial_number_repository.dart';
import 'package:tiresense/features/sensors/domain/usecases/get_serial_number_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/request_sensor_frame_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/watch_sensor_frames_use_case.dart';
import 'package:tiresense/app/sensors_providers.dart';
import 'package:tiresense/features/sensors/presentation/states/serial_number_state.dart';
import 'package:tiresense/features/sensors/presentation/view_models/sensors_view_model.dart';

void main() {
  test('a frame fills readings and loads each serial number', () async {
    final sensors = _FakeSensorRepository();
    final serials = _FakeSerialNumberRepository(Success('SN-2026-0001'));
    final container = _container(sensors, serials);

    await container.read(sensorsViewModelProvider.notifier).requestFrame();
    sensors.emit(_frame(['SENSOR_001']));
    await _flush();

    final state = container.read(sensorsViewModelProvider);
    expect(state.readings['SENSOR_001']?.pressure, 2.2);
    expect(state.staleSensorIds, isEmpty);
    expect(serials.requested, ['SENSOR_001']);
    expect(
      state.serialNumbers['SENSOR_001'],
      isA<SerialNumberReady>().having(
        (ready) => ready.serialNumber,
        'serialNumber',
        'SN-2026-0001',
      ),
    );
  });

  test('a sensor missing from the next frame stays stale', () async {
    final sensors = _FakeSensorRepository();
    final container = _container(
      sensors,
      _FakeSerialNumberRepository(Success('SN-2026-0001')),
    );

    await container.read(sensorsViewModelProvider.notifier).requestFrame();
    sensors.emit(_frame(['SENSOR_001', 'SENSOR_002']));
    sensors.emit(_frame(['SENSOR_002']));
    await _flush();

    final state = container.read(sensorsViewModelProvider);
    expect(state.readings.containsKey('SENSOR_001'), isTrue);
    expect(state.staleSensorIds, {'SENSOR_001'});
  });

  test('a failed serial number can be retried', () async {
    final sensors = _FakeSensorRepository();
    final serials = _FakeSerialNumberRepository(ErrorResult(NetworkFailure()));
    final container = _container(sensors, serials);

    await container.read(sensorsViewModelProvider.notifier).requestFrame();
    sensors.emit(_frame(['SENSOR_001']));
    await _flush();
    expect(
      container.read(sensorsViewModelProvider).serialNumbers['SENSOR_001'],
      isA<SerialNumberFailed>(),
    );

    serials.result = Success('SN-2026-0001');
    await container
        .read(sensorsViewModelProvider.notifier)
        .retrySerialNumber('SENSOR_001');

    expect(
      container.read(sensorsViewModelProvider).serialNumbers['SENSOR_001'],
      isA<SerialNumberReady>(),
    );
  });
}

ProviderContainer _container(
  SensorRepository sensors,
  SerialNumberRepository serials,
) {
  final container = ProviderContainer(
    overrides: [
      watchSensorFramesUseCaseProvider.overrideWithValue(
        WatchSensorFramesUseCase(sensors),
      ),
      requestSensorFrameUseCaseProvider.overrideWithValue(
        RequestSensorFrameUseCase(sensors),
      ),
      getSerialNumberUseCaseProvider.overrideWithValue(
        GetSerialNumberUseCase(serials),
      ),
    ],
  );
  addTearDown(container.dispose);
  container.listen(sensorsViewModelProvider, (_, _) {});
  return container;
}

SensorFrame _frame(List<String> ids) {
  final timestamp = DateTime.utc(2026, 1, 1);
  return SensorFrame(
    timestamp: timestamp,
    readings: [
      for (final id in ids)
        SensorReading(
          id: id,
          pressure: 2.2,
          temperature: 20,
          rssi: -60,
          batteryLevel: 80,
          updatedAt: timestamp,
        ),
    ],
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

final class _FakeSensorRepository implements SensorRepository {
  final StreamController<SensorFrame> _frames =
      StreamController<SensorFrame>.broadcast();

  void emit(SensorFrame frame) => _frames.add(frame);

  @override
  Stream<SensorFrame> watchFrames() => _frames.stream;

  @override
  Future<void> requestFrame() async {}
}

final class _FakeSerialNumberRepository implements SerialNumberRepository {
  Result<String> result;
  final List<String> requested = [];

  _FakeSerialNumberRepository(this.result);

  @override
  Future<Result<String>> getSerialNumber(String sensorId) async {
    requested.add(sensorId);
    return result;
  }
}
