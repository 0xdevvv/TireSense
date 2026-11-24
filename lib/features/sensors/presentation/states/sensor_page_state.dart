import 'package:tiresense/features/sensors/presentation/states/sensors_state.dart';

class SensorPageState {
  final SensorsState sensors;
  final bool isStreaming;
  final String actionLabel;

  const SensorPageState({
    required this.sensors,
    this.isStreaming = false,
    this.actionLabel = '',
  });

  SensorPageState copyWith({
    SensorsState? sensors,
    bool? isStreaming,
    String? actionLabel,
  }) {
    return SensorPageState(
      sensors: sensors ?? this.sensors,
      isStreaming: isStreaming ?? this.isStreaming,
      actionLabel: actionLabel ?? this.actionLabel,
    );
  }
}