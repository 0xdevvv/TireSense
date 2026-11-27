import 'package:tiresense/features/sensors/presentation/states/sensors_state.dart';
import 'package:tiresense/features/settings/domain/models/temperature_unit.dart';

enum SensorButtonAction { simulate, start, stop }

class SensorPageState {
  final SensorsState sensors;
  final bool isStreaming;
  final SensorButtonAction action;
  final TemperatureUnit unit;
  final bool hasStreamError;

  const SensorPageState({
    required this.sensors,
    this.isStreaming = false,
    this.action = SensorButtonAction.simulate,
    this.unit = TemperatureUnit.celsius,
    this.hasStreamError = false,
  });

  SensorPageState copyWith({
    SensorsState? sensors,
    bool? isStreaming,
    SensorButtonAction? action,
    TemperatureUnit? unit,
    bool? hasStreamError,
  }) {
    return SensorPageState(
      sensors: sensors ?? this.sensors,
      isStreaming: isStreaming ?? this.isStreaming,
      action: action ?? this.action,
      unit: unit ?? this.unit,
      hasStreamError: hasStreamError ?? this.hasStreamError,
    );
  }
}