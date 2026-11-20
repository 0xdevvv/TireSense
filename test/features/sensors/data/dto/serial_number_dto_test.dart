import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tiresense/features/sensors/data/dto/serial_number_dto.dart';

void main() {
  group('SerialNumberDto', () {
    test('fromJson reads the serial-number payload', () {
      final json = jsonDecode(
        '{"sensorId":"SENSOR_001","serialNumber":"SN-2026-0001"}',
      ) as Map<String, dynamic>;

      final dto = SerialNumberDto.fromJson(json);

      expect(dto.sensorId, 'SENSOR_001');
      expect(dto.serialNumber, 'SN-2026-0001');
    });

    test('toJson returns the same keys', () {
      const dto = SerialNumberDto(
        sensorId: 'SENSOR_001',
        serialNumber: 'SN-2026-0001',
      );

      expect(dto.toJson(), {
        'sensorId': 'SENSOR_001',
        'serialNumber': 'SN-2026-0001',
      });
    });

    test('fromJson throws when a field is missing or has the wrong type', () {
      expect(
        () => SerialNumberDto.fromJson({'sensorId': 'SENSOR_001'}),
        throwsFormatException,
      );
      expect(
        () => SerialNumberDto.fromJson({
          'sensorId': 'SENSOR_001',
          'serialNumber': 2026,
        }),
        throwsFormatException,
      );
    });
  });
}
