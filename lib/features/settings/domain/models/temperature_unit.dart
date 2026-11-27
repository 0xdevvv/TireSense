enum TemperatureUnit {
  celsius,
  fahrenheit;

  static TemperatureUnit fromName(String name) {
    return TemperatureUnit.values.asNameMap()[name] ?? TemperatureUnit.celsius;
  }
}