import 'package:tiresense/core/usecase/use_case.dart';
import 'package:tiresense/features/settings/domain/models/settings.dart';
import 'package:tiresense/features/settings/domain/repositories/settings_repository.dart';

final class SaveSettingsUseCase implements AsyncUseCaseWithParam<Settings, void> {
  final SettingsRepository _repository;
  
  SaveSettingsUseCase(this._repository);

  @override
  Future<void> execute(Settings settings) => _repository.save(settings);
}