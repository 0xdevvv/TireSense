final class SensorReading {
  final String id;
  final double pressure;
  final double temperature;
  final int rssi;
  final int batteryLevel;
  final DateTime updatedAt;

  const SensorReading({
    required this.id,
    required this.pressure,
    required this.temperature,
    required this.rssi,
    required this.batteryLevel,
    required this.updatedAt,
  });

  SensorReading copyWith({
    String? id,
    double? pressure,
    double? temperature,
    int? rssi,
    int? batteryLevel,
    DateTime? updatedAt,
  }) {
    return SensorReading(
      id: id ?? this.id,
      pressure: pressure ?? this.pressure,
      temperature: temperature ?? this.temperature,
      rssi: rssi ?? this.rssi,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SensorReading &&
      other.id == id &&
      other.pressure == pressure &&
      other.temperature == temperature &&
      other.rssi == rssi &&
      other.batteryLevel == batteryLevel &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      Object.hash(id, pressure, temperature, rssi, batteryLevel, updatedAt);

  @override
  String toString() =>
      'SensorReading($id, ${pressure}bar, $temperature°C, $rssi dBm, $batteryLevel%)';
}
