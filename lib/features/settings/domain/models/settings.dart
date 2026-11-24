import 'package:tiresense/features/settings/domain/models/temperature_unit.dart';

final class Settings {
  final TemperatureUnit unit;
  final bool continuousStream;

  const Settings({
    this.unit = TemperatureUnit.celsius,
    this.continuousStream = false,
  });

  Settings copyWith({
    TemperatureUnit? unit,
    bool? continuousStream,
  }) {
    return Settings(
      unit: unit ?? this.unit,
      continuousStream: continuousStream ?? this.continuousStream,
    );
  }
}
