import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';

abstract class BleSensorDataSource {
  int get sensorCount;
  Future<String> findSensor();
  void addSensor(String sensorId);
  Stream<SensorFrame> frames();
  Future<void> requestFrame();
  void startStream();
  void stopStream();
}
