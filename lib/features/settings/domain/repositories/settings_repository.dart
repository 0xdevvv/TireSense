import 'package:tiresense/features/settings/domain/models/settings.dart';

abstract class SettingsRepository {
  Settings load();

  Future<void> save(Settings settings);
}
