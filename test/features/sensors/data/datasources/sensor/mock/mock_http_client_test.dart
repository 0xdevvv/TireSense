import 'package:flutter_test/flutter_test.dart';
import 'package:tiresense/core/network/http_status_exception.dart';
import 'package:tiresense/features/sensors/data/datasources/sensor/mock/mock_http_client.dart';

void main() {
  group('MockHttpClient', () {
    test('get returns the serial number for a known sensor', () async {
      final client = MockHttpClient.test();

      final body = await client.get('/api/sensors/SENSOR_001/serial-number');

      expect(body, {'sensorId': 'SENSOR_001', 'serialNumber': 'SN-2026-0001'});
    });

    test('get throws 503 when the failure rate is certain', () async {
      final client = MockHttpClient.test(failureRate: 1);

      expect(
        () => client.get('/api/sensors/SENSOR_001/serial-number'),
        throwsA(
          isA<HttpStatusException>().having(
            (error) => error.statusCode,
            'statusCode',
            503,
          ),
        ),
      );
    });

    test('get throws 404 for an unknown sensor', () async {
      final client = MockHttpClient.test();

      expect(
        () => client.get('/api/sensors/SENSOR_999/serial-number'),
        throwsA(
          isA<HttpStatusException>().having(
            (error) => error.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
    });
  });
}
