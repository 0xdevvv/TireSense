import 'package:tiresense/features/sensors/data/dto/serial_number_dto.dart';

abstract class SensorApi {
  Future<SerialNumberDto> getSerialNumber(String sensorId);
}
