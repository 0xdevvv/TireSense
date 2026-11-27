import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiresense/core/result/result.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';
import 'package:tiresense/app/sensors_providers.dart';
import 'package:tiresense/features/sensors/presentation/states/sensor_page_state.dart';
import 'package:tiresense/features/sensors/presentation/states/sensor_state.dart';
import 'package:tiresense/features/sensors/presentation/states/sensors_state.dart';
import 'package:tiresense/features/sensors/presentation/states/serial_number_state.dart';
import 'package:tiresense/features/settings/domain/models/settings.dart';

final sensorsViewModelProvider = NotifierProvider<SensorsViewModel, SensorPageState>(SensorsViewModel.new);

final sensorProvider = Provider.family<SensorState?, String>((ref, sensorId) {
  return ref.watch(sensorsViewModelProvider.select((state) => state.sensors.sensor(sensorId)));
});

final discoveredSensorProvider = FutureProvider.autoDispose<String>((ref) {
  return ref.read(sensorsViewModelProvider.notifier).findSensor();
});

final class SensorsViewModel extends Notifier<SensorPageState> {
  Settings get _settings => ref.read(loadSettingsUseCaseProvider).execute();

  @override
  SensorPageState build() {
    final subscription = ref
        .read(watchSensorFramesUseCaseProvider)
        .execute()
        .listen(_onFrame, onError: _onStreamError);

    ref.onDispose(subscription.cancel);

    return SensorPageState(
      sensors: const SensorsState(),
      action: _action(isStreaming: false),
      unit: _settings.unit,
    );
  }

  Future<String> findSensor() {
    return ref.read(findSensorUseCaseProvider).execute();
  }

  void addSensor(String sensorId) {
    ref.read(addSensorUseCaseProvider).execute(sensorId);
  }

  void reloadSettings() {
    final updatedIsStreaming = _settings.continuousStream && state.isStreaming;
    
    if (state.isStreaming && !updatedIsStreaming) {
      ref.read(setContinuousSensorStreamUseCaseProvider).execute(false);
    }

    state = state.copyWith(
      isStreaming: updatedIsStreaming,
      action: _action(isStreaming: updatedIsStreaming),
      unit: _settings.unit,
    );
  }

  Future<void> requestData({bool firstFrame = false}) async {
    if (firstFrame || !_settings.continuousStream) {
      try {
        await ref.read(requestSensorFrameUseCaseProvider).execute();
      } catch (error, stackTrace) {
        _report(error, stackTrace);
      }
      return;
    }

    if (state.isStreaming) {
      _stopStream();
    } else {
      _startStream();
    }
  }

  void _startStream() {
    _setStreaming(true);
  }

  void _stopStream() {
    _setStreaming(false);
  }

  void _setStreaming(bool isStreaming) {
    ref.read(setContinuousSensorStreamUseCaseProvider).execute(isStreaming);

    state = state.copyWith(
      isStreaming: isStreaming,
      action: _action(isStreaming: isStreaming),
    );
  }

  Future<void> retrySerialNumber(String sensorId) {
    state = state.copyWith(sensors: state.sensors.updateSerialNumber(sensorId, const SerialNumberLoading()));
    return _loadSerialNumber(sensorId);
  }

  void _onFrame(SensorFrame frame) {
    final update = state.sensors.applyFrame(frame);
    state = state.copyWith(sensors: update.state, hasStreamError: false);
    _loadPendingSerialNumbers(update.pendingSerialNumbers);
  }

  void _onStreamError(Object error, StackTrace stackTrace) {
    _report(error, stackTrace);
  }

  void _report(Object error, StackTrace stackTrace) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
    ));
    if (ref.mounted) {
      state = state.copyWith(hasStreamError: true);
    }
  }

  void _loadPendingSerialNumbers(List<String> sensorIds) {
    for (final sensorId in sensorIds) {
      _loadSerialNumber(sensorId);
    }
  }

  Future<void> _loadSerialNumber(String sensorId) async {
    final result = await ref
        .read(getSerialNumberUseCaseProvider)
        .execute(sensorId);

    if (ref.mounted) {
      final serialNumber = switch (result) {
        Success(:final value) => SerialNumberReady(value),
        ErrorResult(:final failure) => SerialNumberFailed(failure),
      };

      state = state.copyWith(sensors: state.sensors.updateSerialNumber(sensorId, serialNumber));
    }
  }

  SensorButtonAction _action({required bool isStreaming}) {
    if (!_settings.continuousStream) return SensorButtonAction.simulate;
    if (isStreaming) return SensorButtonAction.stop;
    return SensorButtonAction.start;
  }
}
