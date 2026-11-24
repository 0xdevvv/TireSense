import 'package:tiresense/core/usecase/use_case.dart';
import 'package:tiresense/features/settings/domain/models/settings.dart';
import 'package:tiresense/features/settings/domain/repositories/settings_repository.dart';

class LoadSettingsUseCase implements UseCase<Settings> {
  final SettingsRepository _repository;

  LoadSettingsUseCase(this._repository);

  @override
  Settings execute() {
    return _repository.load();
  }
}