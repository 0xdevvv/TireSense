import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiresense/core/result/result.dart';
import 'package:tiresense/features/sensors/domain/exceptions/sensor_limit_reaached_exception.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';
import 'package:tiresense/app/sensors_providers.dart';
import 'package:tiresense/features/sensors/presentation/states/sensor_page_state.dart';
import 'package:tiresense/features/sensors/presentation/states/sensor_state.dart';
import 'package:tiresense/features/sensors/presentation/states/sensors_state.dart';
import 'package:tiresense/features/sensors/presentation/states/serial_number_state.dart';

final sensorsViewModelProvider = NotifierProvider<SensorsViewModel, SensorPageState>(SensorsViewModel.new);

final sensorProvider = Provider.family<SensorState?, String>((ref, sensorId) {
  return ref.watch(sensorsViewModelProvider.select((state) => state.sensors.sensor(sensorId)));
});

final discoveredSensorProvider = FutureProvider.autoDispose<String>((ref) {
  return ref.watch(findSensorUseCaseProvider).execute();
});

final class SensorsViewModel extends Notifier<SensorPageState> {
  bool get _continuousStreamSettings => ref.read(loadSettingsUseCaseProvider).execute().continuousStream;

  @override
  SensorPageState build() {
    final subscription = ref
        .read(watchSensorFramesUseCaseProvider)
        .execute()
        .listen(_onFrame);

    ref.onDispose(subscription.cancel);

    return SensorPageState(
      sensors: const SensorsState(),
      action: _action(isStreaming: false),
    );
  }

  bool addSensor(String sensorId) {
    try {
      ref.read(addSensorUseCaseProvider).execute(sensorId);
      return true;
    } on SensorLimitReachedException catch (_) {
      return false;
    } 
  }

  void updateState() {
    final updatedIsStreaming = _continuousStreamSettings && state.isStreaming;
    
    if (state.isStreaming && !updatedIsStreaming) {
      ref.read(setContinuousSensorStreamUseCaseProvider).execute(false);
    }

    state = state.copyWith(
      isStreaming: updatedIsStreaming,
      action: _action(isStreaming: updatedIsStreaming),
    );
  }

  Future<void> requestData({bool firstFrame = false}) {
    if (firstFrame || !_continuousStreamSettings) {
      return ref.read(requestSensorFrameUseCaseProvider).execute();
    }

    if (state.isStreaming) {
      _stopStream();
    } else {
      _startStream();
    }
    
    return Future<void>.value();
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
    state = state.copyWith(sensors: update.state);
    _loadPendingSerialNumbers(update.pendingSerialNumbers);
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
    if (!_continuousStreamSettings) return SensorButtonAction.simulate;
    if (isStreaming) return SensorButtonAction.stop;
    return SensorButtonAction.start;
  }
}
