import 'dart:math';

import 'package:tiresense/core/network/http_client.dart';
import 'package:tiresense/core/network/http_status_exception.dart';
import 'package:tiresense/features/sensors/data/dto/serial_number_dto.dart';

final class MockHttpClient implements HttpClient {
  static const _sensorIds = [
    'SENSOR_001',
    'SENSOR_002',
    'SENSOR_003',
    'SENSOR_004',
  ];

  final Map<String, Map<String, dynamic>> _routes = _buildRoutes();
  final Random _random = Random();
  final double _failureRate;
  final Duration? _latency;

  MockHttpClient()
    : _failureRate = 0.2,
      _latency = null;

  MockHttpClient.test({this._failureRate = 0, this._latency = Duration.zero});

  @override
  Future<Map<String, dynamic>> get(String path) async {
    final milliseconds = 300 + _random.nextInt(901);
    final latency = _latency ?? Duration(milliseconds: milliseconds);
    await Future<void>.delayed(latency);
    if (_failureRate > 0 && _random.nextDouble() < _failureRate) {
      throw HttpStatusException(503, path);
    }
    final body = _routes[path];
    if (body == null) {
      throw HttpStatusException(404, path);
    }
    return body;
  }

  static Map<String, Map<String, dynamic>> _buildRoutes() {
    final routes = <String, Map<String, dynamic>>{};
    for (final id in _sensorIds) {
      final serialNumber = id.substring(id.length - 3).padLeft(4, '0');
      routes['/api/sensors/$id/serial-number'] = SerialNumberDto(
        sensorId: id,
        serialNumber: 'SN-2026-$serialNumber',
      ).toJson();
    }
    return routes;
  }
}
