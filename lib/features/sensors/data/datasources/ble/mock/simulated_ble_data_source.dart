import 'dart:async';
import 'dart:math';

import 'package:tiresense/features/sensors/data/datasources/ble/api/ble_sensor_data_source.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_reading.dart';

final class SimulatedBleDataSource implements BleSensorDataSource {
  static const _defaultSensorIds = [
    'SENSOR_001',
    'SENSOR_002',
    'SENSOR_003',
    'SENSOR_004',
  ];

  static const _missingRate = 0.1;
  static const _frameDelay = Duration(milliseconds: 40);
  static const _streamInterval = Duration(seconds: 2);

  final Set<String> _sensorIds = <String>{..._defaultSensorIds};
  final Random _random = Random();
  final Map<String, int> _batteryLevel = {};
  final StreamController<SensorFrame> _controller = StreamController<SensorFrame>.broadcast();

  int _frameCount = 0;
  Timer? _stream;

  @override
  Stream<SensorFrame> frames() => _controller.stream;

  @override
  Future<String> findSensor() async {
    await Future.delayed(const Duration(seconds: 2));
    final next = _sensorIds.length + 1;
    return 'SENSOR_${next.toString().padLeft(3, '0')}';
  }

  @override
  void addSensor(String sensorId) {
    if (_sensorIds.contains(sensorId)) return;
    _sensorIds.add(sensorId);
    _controller.add(_nextFrame(requiredId: sensorId));
  }

  @override
  Future<void> requestFrame() async {
    await Future<void>.delayed(_frameDelay);
    _controller.add(_nextFrame());
  }

  @override
  void startStream() {
    _stream ??= Timer.periodic(_streamInterval, (_) {
      _controller.add(_nextFrame());
    });
  }

  @override
  void stopStream() {
    _stream?.cancel();
    _stream = null;
  }

  SensorFrame _nextFrame({String? requiredId}) {
    final timestamp = DateTime.now();
    final readings = <SensorReading>[];
    for (final id in _sensorIds) {
      // The first frame includes every sensor so the screen starts populated.
      final missing = id != requiredId && _frameCount > 0 && _random.nextDouble() < _missingRate;
      if (missing) {
        continue;
      }
      readings.add(_reading(id, timestamp));
    }
    _frameCount++;
    return SensorFrame(timestamp: timestamp, readings: readings);
  }

  SensorReading _reading(String id, DateTime timestamp) {
    final pressure = 1.8 + (_random.nextInt(121) / 100);
    final temperature = 15 + (_random.nextInt(451) / 10);
    final rssi = -100 + _random.nextInt(61);
    final batteryLevel = _nextBatteryLevel(id);

    return SensorReading(
      id: id,
      pressure: pressure,
      temperature: temperature,
      rssi: rssi,
      batteryLevel: batteryLevel,
      updatedAt: timestamp,
    );
  }

  int _nextBatteryLevel(String id) {
    final previous = _batteryLevel[id];
    final level = previous == null
        ? 70 + _random.nextInt(31)
        : max(0, previous - _random.nextInt(2));

    _batteryLevel[id] = level;
    return level;
  }

  void dispose() {
    _controller.close();
    stopStream();
  }
}
