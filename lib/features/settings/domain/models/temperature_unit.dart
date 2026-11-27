enum TemperatureUnit {
  celsius,
  fahrenheit;

  String get name => switch (this) {
    TemperatureUnit.celsius => 'celsius',
    TemperatureUnit.fahrenheit => 'fahrenheit',
  };

  static TemperatureUnit fromName(String name) {
    return TemperatureUnit.values.asNameMap()[name] ?? TemperatureUnit.celsius;
  }
}