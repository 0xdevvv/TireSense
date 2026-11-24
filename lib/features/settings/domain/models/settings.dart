import 'package:tiresense/features/settings/domain/models/temperature_unit.dart';

final class Settings {
  final TemperatureUnit unit;
  final bool liveStream;

  const Settings({
    this.unit = TemperatureUnit.celsius,
    this.liveStream = false,
  });

  Settings copyWith({
    TemperatureUnit? unit,
    bool? liveStream,
  }) {
    return Settings(
      unit: unit ?? this.unit,
      liveStream: liveStream ?? this.liveStream,
    );
  }
}
