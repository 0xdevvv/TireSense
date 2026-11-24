import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiresense/features/settings/domain/models/settings.dart';
import 'package:tiresense/features/settings/domain/models/temperature_unit.dart';
import 'package:tiresense/features/settings/domain/repositories/settings_repository.dart';

final class SettingsRepositoryImpl implements SettingsRepository {
  static const _unitKey = 'settings.temperature_unit';
  static const _continuousStreamKey = 'settings.continuous_stream';

  final SharedPreferences _preferences;

  const SettingsRepositoryImpl(this._preferences);

  @override
  Settings load() {
    final unitName = _preferences.getString(_unitKey) ?? TemperatureUnit.celsius.name;
    
    return Settings(
      unit: TemperatureUnit.fromName(unitName),
      continuousStream: _preferences.getBool(_continuousStreamKey) ?? false,
    );
  }

  @override
  Future<void> save(Settings settings) async {
    await _preferences.setString(_unitKey, settings.unit.name);
    await _preferences.setBool(_continuousStreamKey, settings.continuousStream);
  }
}
