import 'package:flutter_test/flutter_test.dart';
import 'package:tiresense/core/network/http_client.dart';
import 'package:tiresense/features/sensors/data/datasources/sensor/impl/sensor_api_impl.dart';

void main() {
  group('SensorApiImpl', () {
    test(
      'getSerialNumber asks for the sensor path and parses the dto',
      () async {
        final client = _RecordingClient({
          'sensorId': 'SENSOR_002',
          'serialNumber': 'SN-2026-0002',
        });
        final api = SensorApiImpl(client);

        final dto = await api.getSerialNumber('SENSOR_002');

        expect(client.lastPath, '/api/sensors/SENSOR_002/serial-number');
        expect(dto.sensorId, 'SENSOR_002');
        expect(dto.serialNumber, 'SN-2026-0002');
      },
    );
  });
}

final class _RecordingClient implements HttpClient {
  final Map<String, dynamic> body;
  String? lastPath;

  _RecordingClient(this.body);

  @override
  Future<Map<String, dynamic>> get(String path) async {
    lastPath = path;
    return body;
  }
}
