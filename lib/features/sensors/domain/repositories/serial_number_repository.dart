import 'package:tiresense/core/result.dart';

abstract class SerialNumberRepository {
  Future<Result<String>> getSerialNumber(String sensorId);
}
