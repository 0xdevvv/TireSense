import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';

abstract class SensorRepository {
  Future<String> findSensor();
  void addSensor(String sensorId);
  Stream<SensorFrame> watchFrames();
  Future<void> requestFrame();
  void startStream();
  void stopStream();
}
