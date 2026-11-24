import 'package:tiresense/features/sensors/presentation/states/sensors_state.dart';

enum SensorButtonAction { simulate, start, stop }

class SensorPageState {
  final SensorsState sensors;
  final bool isStreaming;
  final SensorButtonAction action;

  const SensorPageState({
    required this.sensors,
    this.isStreaming = false,
    this.action = SensorButtonAction.simulate,
  });

  SensorPageState copyWith({
    SensorsState? sensors,
    bool? isStreaming,
    SensorButtonAction? action,
  }) {
    return SensorPageState(
      sensors: sensors ?? this.sensors,
      isStreaming: isStreaming ?? this.isStreaming,
      action: action ?? this.action,
    );
  }
}