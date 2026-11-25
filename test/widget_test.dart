import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiresense/core/result/result.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';
import 'package:tiresense/features/sensors/domain/repositories/sensor_repository.dart';
import 'package:tiresense/features/sensors/domain/repositories/serial_number_repository.dart';
import 'package:tiresense/features/sensors/domain/usecases/get_serial_number_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/request_sensor_frame_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/watch_sensor_frames_use_case.dart';
import 'package:tiresense/features/settings/domain/models/settings.dart';
import 'package:tiresense/features/settings/domain/repositories/settings_repository.dart';
import 'package:tiresense/features/settings/domain/usecases/load_settings_use_case.dart';
import 'package:tiresense/app/sensors_providers.dart';
import 'package:tiresense/main.dart';

void main() {
  testWidgets('the dashboard shows the title and the simulate button', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: _overrides(), child: const TireSenseApp()),
    );

    expect(find.text('TireSense'), findsOneWidget);
    final button = tester.getTopLeft(find.text('Simulate Sensor Update'));
    expect(button.dy, greaterThan(500));
    expect(find.text('Simulate Sensor Update'), findsOneWidget);
  });

  testWidgets('dark mode follows the platform', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      ProviderScope(overrides: _overrides(), child: const TireSenseApp()),
    );

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
  });
}

List<Override> _overrides() {
  final sensors = _SilentSensorRepository();
  return [
    watchSensorFramesUseCaseProvider.overrideWithValue(
      WatchSensorFramesUseCase(sensors),
    ),
    requestSensorFrameUseCaseProvider.overrideWithValue(
      RequestSensorFrameUseCase(sensors),
    ),
    getSerialNumberUseCaseProvider.overrideWithValue(
      GetSerialNumberUseCase(_SilentSerialNumberRepository()),
    ),
    loadSettingsUseCaseProvider.overrideWithValue(
      LoadSettingsUseCase(_FixedSettingsRepository()),
    ),
  ];
}

final class _SilentSensorRepository implements SensorRepository {
  @override
  Stream<SensorFrame> watchFrames() => const Stream.empty();

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

final class _SilentSerialNumberRepository implements SerialNumberRepository {
  @override
  Future<Result<String>> getSerialNumber(String sensorId) async {
    return Success(sensorId);
  }
}
