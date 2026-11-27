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
import 'package:tiresense/features/settings/domain/models/settings.dart';
import 'package:tiresense/features/settings/domain/repositories/settings_repository.dart';
import 'package:tiresense/features/settings/domain/usecases/load_settings_use_case.dart';
import 'package:tiresense/app/sensors_providers.dart';
import 'package:tiresense/features/sensors/presentation/states/serial_number_state.dart';
import 'package:tiresense/features/sensors/presentation/view_models/sensors_view_model.dart';

void main() {
  test('a frame fills readings and loads each serial number', () async {
    final sensors = _FakeSensorRepository();
    final serials = _FakeSerialNumberRepository(Success('SN-2026-0001'));
    final container = _container(sensors, serials);

    await container.read(sensorsViewModelProvider.notifier).requestData();
    sensors.emit(_frame(['SENSOR_001']));
    await _flush();

    final state = container.read(sensorsViewModelProvider);
    expect(state.sensors.sensor('SENSOR_001')!.reading.pressure, 2.2);
    expect(state.sensors.sensor('SENSOR_001')!.isStale, isFalse);
    expect(serials.requested, ['SENSOR_001']);
    expect(
      state.sensors.sensor('SENSOR_001')!.serialNumber,
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

    await container.read(sensorsViewModelProvider.notifier).requestData();
    sensors.emit(_frame(['SENSOR_001', 'SENSOR_002']));
    sensors.emit(_frame(['SENSOR_002']));
    await _flush();

    final state = container.read(sensorsViewModelProvider);
    expect(state.sensors.sensor('SENSOR_001'), isNotNull);
    expect(state.sensors.sensor('SENSOR_001')!.isStale, isTrue);
  });

  test('the next frame requests a failed serial number again', () async {
    final sensors = _FakeSensorRepository();
    final serials = _FakeSerialNumberRepository(ErrorResult(NetworkFailure()));
    final container = _container(sensors, serials);

    await container.read(sensorsViewModelProvider.notifier).requestData();
    sensors.emit(_frame(['SENSOR_001']));
    await _flush();

    serials.result = Success('SN-2026-0001');
    sensors.emit(_frame(['SENSOR_001']));
    await _flush();

    expect(
      container
          .read(sensorsViewModelProvider)
          .sensors.sensor('SENSOR_001')!
          .serialNumber,
      isA<SerialNumberReady>(),
    );
    expect(serials.requested, ['SENSOR_001', 'SENSOR_001']);
  });

  test('a missing serial number is not requested again', () async {
    final sensors = _FakeSensorRepository();
    final serials = _FakeSerialNumberRepository(ErrorResult(NotFoundFailure()));
    final container = _container(sensors, serials);

    await container.read(sensorsViewModelProvider.notifier).requestData();
    sensors.emit(_frame(['SENSOR_001']));
    await _flush();
    sensors.emit(_frame(['SENSOR_001']));
    await _flush();

    expect(serials.requested, ['SENSOR_001']);
  });

  test('a failed serial number can be retried', () async {
    final sensors = _FakeSensorRepository();
    final serials = _FakeSerialNumberRepository(ErrorResult(NetworkFailure()));
    final container = _container(sensors, serials);

    await container.read(sensorsViewModelProvider.notifier).requestData();
    sensors.emit(_frame(['SENSOR_001']));
    await _flush();
    expect(
      container
          .read(sensorsViewModelProvider)
          .sensors.sensor('SENSOR_001')!
          .serialNumber,
      isA<SerialNumberFailed>(),
    );

    serials.result = Success('SN-2026-0001');
    await container
        .read(sensorsViewModelProvider.notifier)
        .retrySerialNumber('SENSOR_001');

    expect(
      container
          .read(sensorsViewModelProvider)
          .sensors.sensor('SENSOR_001')!
          .serialNumber,
      isA<SerialNumberReady>(),
    );
  });

  test('sensorProvider reads one sensor', () async {
    final sensors = _FakeSensorRepository();
    final container = _container(
      sensors,
      _FakeSerialNumberRepository(Success('SN-2026-0001')),
    );

    await container.read(sensorsViewModelProvider.notifier).requestData();
    sensors.emit(_frame(['SENSOR_001', 'SENSOR_002']));
    await _flush();

    expect(
      container.read(sensorProvider('SENSOR_001'))!.reading.pressure,
      2.2,
    );
    expect(container.read(sensorProvider('SENSOR_002')), isNotNull);
    expect(container.read(sensorProvider('SENSOR_003')), isNull);
  });

  test('a serial number update notifies only that sensor provider', () async {
    final sensors = _FakeSensorRepository();
    final container = _container(
      sensors,
      _FakeSerialNumberRepository(Success('SN-2026-0001')),
    );

    await container.read(sensorsViewModelProvider.notifier).requestData();
    sensors.emit(_frame(['SENSOR_001', 'SENSOR_002']));
    await _flush();

    final updated = <String>[];
    container.listen(
      sensorProvider('SENSOR_001'),
      (_, _) => updated.add('SENSOR_001'),
    );
    container.listen(
      sensorProvider('SENSOR_002'),
      (_, _) => updated.add('SENSOR_002'),
    );
    var idsChanged = false;
    container.listen(
      sensorsViewModelProvider.select((state) => state.sensors.sensorIds),
      (_, _) => idsChanged = true,
    );

    await container
        .read(sensorsViewModelProvider.notifier)
        .retrySerialNumber('SENSOR_001');
    await _flush();

    expect(updated, ['SENSOR_001']);
    expect(idsChanged, isFalse);
    expect(
      container.read(sensorProvider('SENSOR_001'))!.serialNumber,
      isA<SerialNumberReady>(),
    );
  });

  test('a frame with the same sensors keeps the id list', () async {
    final sensors = _FakeSensorRepository();
    final container = _container(
      sensors,
      _FakeSerialNumberRepository(Success('SN-2026-0001')),
    );

    await container.read(sensorsViewModelProvider.notifier).requestData();
    sensors.emit(_frame(['SENSOR_001', 'SENSOR_002']));
    await _flush();
    final ids = container.read(sensorsViewModelProvider).sensors.sensorIds;

    var idsChanged = false;
    container.listen(
      sensorsViewModelProvider.select((state) => state.sensors.sensorIds),
      (_, _) => idsChanged = true,
    );

    sensors.emit(_frame(['SENSOR_002', 'SENSOR_001']));
    await _flush();

    expect(idsChanged, isFalse);
    expect(
      identical(container.read(sensorsViewModelProvider).sensors.sensorIds, ids),
      isTrue,
    );
  });

  test('a new sensor replaces the id list', () async {
    final sensors = _FakeSensorRepository();
    final container = _container(
      sensors,
      _FakeSerialNumberRepository(Success('SN-2026-0001')),
    );

    await container.read(sensorsViewModelProvider.notifier).requestData();
    sensors.emit(_frame(['SENSOR_001']));
    await _flush();
    final ids = container.read(sensorsViewModelProvider).sensors.sensorIds;

    var idsChanged = false;
    container.listen(
      sensorsViewModelProvider.select((state) => state.sensors.sensorIds),
      (_, _) => idsChanged = true,
    );

    sensors.emit(_frame(['SENSOR_001', 'SENSOR_002']));
    await _flush();

    expect(idsChanged, isTrue);
    expect(container.read(sensorsViewModelProvider).sensors.sensorIds, [
      'SENSOR_001',
      'SENSOR_002',
    ]);
    expect(
      identical(container.read(sensorsViewModelProvider).sensors.sensorIds, ids),
      isFalse,
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
      loadSettingsUseCaseProvider.overrideWithValue(
        LoadSettingsUseCase(_FixedSettingsRepository()),
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

final class _FixedSettingsRepository implements SettingsRepository {
  @override
  Settings load() => const Settings();

  @override
  Future<void> save(Settings settings) async {}
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
