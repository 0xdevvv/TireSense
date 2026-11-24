import 'package:tiresense/features/sensors/presentation/states/sensors_state.dart';

class SensorPageState {
  final SensorsState sensors;
  final bool streaming;
  final String actionLabel;

  const SensorPageState({
    required this.sensors,
    this.streaming = false,
    this.actionLabel = '',
  });

  SensorPageState copyWith({
    SensorsState? sensors,
    bool? streaming,
    String? actionLabel,
  }) {
    return SensorPageState(
      sensors: sensors ?? this.sensors,
      streaming: streaming ?? this.streaming,
      actionLabel: actionLabel ?? this.actionLabel,
    );
  }
}