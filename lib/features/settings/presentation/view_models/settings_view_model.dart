import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiresense/app/sensors_providers.dart';
import 'package:tiresense/features/settings/domain/models/settings.dart';
import 'package:tiresense/features/settings/domain/models/temperature_unit.dart';

final settingsViewModelProvider = NotifierProvider<SettingsViewModel, Settings>(SettingsViewModel.new);

final class SettingsViewModel extends Notifier<Settings> {
  @override
  Settings build() {
    final settings = ref.read(loadSettingsUseCaseProvider).execute();

    return Settings(
      unit: settings.unit,
      continuousStream: settings.continuousStream,
    );
  }

  void setUnit(TemperatureUnit unit) {  
     _save(state.copyWith(unit: unit));
  }

  void setContinuousStream(bool continuousStream) {
    _save(state.copyWith(continuousStream: continuousStream));
  }

  void _save(Settings settings) {
    state = settings;
    ref.read(saveSettingsUseCaseProvider).execute(settings);
  }
}