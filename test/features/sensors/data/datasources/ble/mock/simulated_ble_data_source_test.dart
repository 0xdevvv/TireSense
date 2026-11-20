import 'package:flutter_test/flutter_test.dart';
import 'package:tiresense/features/sensors/data/datasources/ble/mock/simulated_ble_data_source.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_frame.dart';
import 'package:tiresense/features/sensors/domain/models/sensor_reading.dart';

void main() {
  const ids = SimulatedBleDataSource.defaultSensorIds;

  Future<List<SensorFrame>> takeFrames(int count) async {
    final dataSource = SimulatedBleDataSource();
    final pending = dataSource.frames().take(count).toList();
    for (var i = 0; i < count; i++) {
      await dataSource.requestFrame();
    }
    return pending;
  }

  group('SimulatedBleDataSource', () {
    test('first frame contains every sensor id', () async {
      final frame = (await takeFrames(1)).single;

      expect(frame.readings.map((reading) => reading.id), ids);
      for (final reading in frame.readings) {
        expect(reading.updatedAt, frame.timestamp);
      }
    });

    test('readings stay inside the simulated ranges', () async {
      final frame = (await takeFrames(1)).single;

      for (final reading in frame.readings) {
        expect(reading.pressure, inInclusiveRange(1.8, 3));
        expect(reading.temperature, inInclusiveRange(15, 60));
        expect(reading.rssi, inInclusiveRange(-100, -40));
        expect(reading.batteryLevel, inInclusiveRange(70, 100));
      }
    });

    test('later readings keep known ids and do not raise battery', () async {
      final frames = await takeFrames(2);
      final firstById = {
        for (final reading in frames.first.readings) reading.id: reading,
      };

      for (final SensorReading reading in frames.last.readings) {
        expect(ids, contains(reading.id));
        expect(
          reading.batteryLevel,
          lessThanOrEqualTo(firstById[reading.id]!.batteryLevel),
        );
      }
    });
  });
}
