import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiresense/core/result/result.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';
import 'package:tiresense/app/sensors_providers.dart';
import 'package:tiresense/features/sensors/presentation/states/sensors_state.dart';
import 'package:tiresense/features/sensors/presentation/states/serial_number_state.dart';

final sensorsViewModelProvider =
    NotifierProvider<SensorsViewModel, SensorsState>(SensorsViewModel.new);

final class SensorsViewModel extends Notifier<SensorsState> {
  @override
  SensorsState build() {
    final subscription = ref
        .read(watchSensorFramesUseCaseProvider)
        .execute()
        .listen(_onFrame);

    ref.onDispose(subscription.cancel);

    return const SensorsState();
  }

  Future<void> requestFrame() {
    return ref.read(requestSensorFrameUseCaseProvider).execute();
  }

  Future<void> retrySerialNumber(String sensorId) {
    state = state.updateSerialNumber(sensorId, const SerialNumberLoading());
    return _loadSerialNumber(sensorId);
  }

  void _onFrame(SensorFrame frame) {
    final readings = Map.of(state.readings);
    final serialNumbers = Map.of(state.serialNumbers);

    final arrived = <String>{};
    final pendingSerialNumbers = <String>[];

    for (final reading in frame.readings) {
      arrived.add(reading.id);
      readings[reading.id] = reading;

      if (!serialNumbers.containsKey(reading.id)) {
        serialNumbers[reading.id] = const SerialNumberLoading();
        pendingSerialNumbers.add(reading.id);
      }
    }

    final staleSensorIds = readings.keys.toSet().difference(arrived);

    state = state.copyWith(
      readings: readings,
      serialNumbers: serialNumbers,
      staleSensorIds: staleSensorIds,
      lastUpdated: frame.timestamp,
    );

    _loadPendingSerialNumbers(pendingSerialNumbers);
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

      state = state.updateSerialNumber(sensorId, serialNumber);
    }
  }
}
