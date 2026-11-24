import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';

abstract class SensorRepository {
  Stream<SensorFrame> watchFrames();
  Future<void> requestFrame();
  void startStream();
  void stopStream();
}
