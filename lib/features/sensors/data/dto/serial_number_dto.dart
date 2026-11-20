final class SerialNumberDto {
  final String sensorId;
  final String serialNumber;

  const SerialNumberDto({required this.sensorId, required this.serialNumber});

  factory SerialNumberDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'sensorId': final String sensorId,
        'serialNumber': final String serialNumber,
      } =>
        SerialNumberDto(sensorId: sensorId, serialNumber: serialNumber),
      _ => throw const FormatException('Invalid serial number payload.'),
    };
  }

  Map<String, dynamic> toJson() {
    return {'sensorId': sensorId, 'serialNumber': serialNumber};
  }
}
