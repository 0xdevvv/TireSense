enum TemperatureUnit {
  celsius,
  fahrenheit;

  String get name => switch (this) {
    TemperatureUnit.celsius => 'celsius',
    TemperatureUnit.fahrenheit => 'fahrenheit',
  };

  static TemperatureUnit fromName(String name) {
    return switch (name) {
      'celsius' => TemperatureUnit.celsius,
      'fahrenheit' => TemperatureUnit.fahrenheit,
      _ => throw ArgumentError.value(name, 'name', 'Invalid temperature unit name'),
    };
  }
}