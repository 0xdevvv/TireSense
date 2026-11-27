import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiresense/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:tiresense/features/settings/domain/models/settings.dart';
import 'package:tiresense/features/settings/domain/models/temperature_unit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fromName falls back to celsius for an unknown name', () {
    expect(TemperatureUnit.fromName('kelvin'), TemperatureUnit.celsius);
  });

  test('load falls back when the stored name is unknown, and save replaces it', () async {
    SharedPreferences.setMockInitialValues({
      'settings.temperature_unit': 'kelvin',
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = SettingsRepositoryImpl(preferences);

    expect(repository.load().unit, TemperatureUnit.celsius);
    expect(repository.load().continuousStream, isFalse);

    await repository.save(const Settings(
      unit: TemperatureUnit.fahrenheit,
      continuousStream: true,
    ));

    expect(repository.load().unit, TemperatureUnit.fahrenheit);
    expect(repository.load().continuousStream, isTrue);
  });
}
