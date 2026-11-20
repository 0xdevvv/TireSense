import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';

abstract class BleSensorDataSource {
  Stream<SensorFrame> frames();

  Future<void> requestFrame();
}
