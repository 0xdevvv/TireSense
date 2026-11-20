import 'package:tiresense/core/network/http_client.dart';
import 'package:tiresense/features/sensors/data/datasources/sensor/api/sensor_api.dart';
import 'package:tiresense/features/sensors/data/dto/serial_number_dto.dart';

final class SensorApiImpl implements SensorApi {
  final HttpClient _client;

  SensorApiImpl(this._client);

  @override
  Future<SerialNumberDto> getSerialNumber(String sensorId) async {
    final json = await _client.get('/api/sensors/$sensorId/serial-number');
    return SerialNumberDto.fromJson(json);
  }
}
