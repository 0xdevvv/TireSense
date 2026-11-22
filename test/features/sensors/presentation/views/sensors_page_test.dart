import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiresense/app/sensors_providers.dart';
import 'package:tiresense/core/result/failure.dart';
import 'package:tiresense/core/result/result.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_reading.dart';
import 'package:tiresense/features/sensors/domain/repositories/sensor_repository.dart';
import 'package:tiresense/features/sensors/domain/repositories/serial_number_repository.dart';
import 'package:tiresense/features/sensors/domain/usecases/get_serial_number_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/request_sensor_frame_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/watch_sensor_frames_use_case.dart';
import 'package:tiresense/main.dart';

void main() {
  testWidgets('a frame renders each sensor and a missing one stays stale', (
    tester,
  ) async {
    final sensors = _FakeSensorRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(sensors, Success('SN-2026-0001')),
        child: const TireSenseApp(),
      ),
    );
    await tester.pump();

    sensors.emit(_frame(['SENSOR_001', 'SENSOR_002']));
    await tester.pump();
    sensors.emit(_frame(['SENSOR_002']));
    await tester.pump();

    expect(find.text('SENSOR_001', skipOffstage: false), findsOneWidget);
    expect(find.text('SENSOR_002', skipOffstage: false), findsOneWidget);
    expect(find.text('2.20 bar', skipOffstage: false), findsWidgets);
    expect(find.text('SN-2026-0001', skipOffstage: false), findsNWidgets(2));
    expect(find.text('Stale', skipOffstage: false), findsOneWidget);
  });

  testWidgets('a failed serial number can be retried from the card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final sensors = _FakeSensorRepository();
    final serials = _FakeSerialNumberRepository(ErrorResult(NetworkFailure()));
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(sensors, serials),
        child: const TireSenseApp(),
      ),
    );
    await tester.pump();

    sensors.emit(_frame(['SENSOR_001']));
    await tester.pump();

    expect(
      find.text('Network request failed', skipOffstage: false),
      findsOneWidget,
    );

    serials.result = Success('SN-2026-0001');
    await tester.tap(find.text('Retry', skipOffstage: false));
    await tester.pump();

    expect(find.text('SN-2026-0001', skipOffstage: false), findsOneWidget);
  });

  testWidgets('scrolling collapses the large title', (tester) async {
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final sensors = _FakeSensorRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: _overrides(sensors, Success('SN-2026-0001')),
        child: const TireSenseApp(),
      ),
    );
    await tester.pump();
    sensors.emit(
      _frame(['SENSOR_001', 'SENSOR_002', 'SENSOR_003', 'SENSOR_004']),
    );
    await tester.pump();

    final expanded = tester.widget<Text>(
      find.text('TireSense', skipOffstage: false),
    );
    expect(expanded.style?.fontSize, greaterThan(24));

    tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position
        .jumpTo(120);
    await tester.pump();

    final collapsed = tester.widget<Text>(
      find.text('TireSense', skipOffstage: false),
    );
    expect(collapsed.style?.fontSize, lessThan(20));
  });
}

List<Override> _overrides(SensorRepository sensors, Object serials) {
  final SerialNumberRepository repository = serials is SerialNumberRepository
      ? serials
      : _FakeSerialNumberRepository(serials as Result<String>);
  return [
    watchSensorFramesUseCaseProvider.overrideWithValue(
      WatchSensorFramesUseCase(sensors),
    ),
    requestSensorFrameUseCaseProvider.overrideWithValue(
      RequestSensorFrameUseCase(sensors),
    ),
    getSerialNumberUseCaseProvider.overrideWithValue(
      GetSerialNumberUseCase(repository),
    ),
  ];
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

  _FakeSerialNumberRepository(this.result);

  @override
  Future<Result<String>> getSerialNumber(String sensorId) async {
    return result;
  }
}
