import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiresense/core/result/result.dart';
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

final class SensorsViewModel extends Notifier<SensorPageState> {
  bool get _liveStream => ref.read(loadSettingsUseCaseProvider).execute().liveStream;

  @override
  SensorPageState build() {
    final subscription = ref
        .read(watchSensorFramesUseCaseProvider)
        .execute()
        .listen(_onFrame);

    ref.onDispose(subscription.cancel);

    return SensorPageState(
      sensors: const SensorsState(),
      actionLabel: _actionLabel(streaming: false),
    );
  }

  void updateState() {
    state = state.copyWith(
      actionLabel: _actionLabel(streaming: state.streaming),
    );
  }

  Future<void> requestData({bool firstFrame = false}) {
    if (firstFrame || !_liveStream) {
      return ref.read(requestSensorFrameUseCaseProvider).execute();
    }

    if (state.streaming) {
      _stopStream();
    } else {
      _startStream();
    }
    
    return Future<void>.value();
  }

  void _startStream() {
    ref.read(setLiveSensorStreamUseCaseProvider).execute(true);
    _setStreaming(true);
  }

  void _stopStream() {
    ref.read(setLiveSensorStreamUseCaseProvider).execute(false);
    _setStreaming(false);
  }

  void _setStreaming(bool streaming) {
    state = state.copyWith(
      streaming: streaming,
      actionLabel: _actionLabel(streaming: streaming),
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

  String _actionLabel({required bool streaming}) {
    if (!_liveStream) return 'Simulate Sensor Update';
    if (streaming) return 'Stop Sensor Stream';
    return 'Start Sensor Stream';
  }
}
