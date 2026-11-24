import 'package:tiresense/features/settings/domain/models/temperature_unit.dart';

extension TemperatureUnitText on TemperatureUnit {
  String format(double celsius) {
    return switch (this) {
      TemperatureUnit.celsius => '${celsius.toStringAsFixed(1)} °C',
      TemperatureUnit.fahrenheit =>
        '${(celsius * 9 / 5 + 32).toStringAsFixed(1)} °F',
    };
  }
}