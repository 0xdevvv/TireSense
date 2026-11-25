// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get simulateSensorUpdate => 'Simular atualização dos sensores';

  @override
  String get startSensorStream => 'Iniciar fluxo contínuo';

  @override
  String get stopSensorStream => 'Parar fluxo contínuo';

  @override
  String get addSensor => 'Adicionar sensor';

  @override
  String get add => 'Adicionar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get searchingForSensor => 'A procurar um sensor';

  @override
  String get noSensorFound => 'Nenhum sensor encontrado';

  @override
  String get sensorAdded => 'Sensor adicionado';

  @override
  String get settings => 'Definições';

  @override
  String get continuousSensorStream => 'Fluxo contínuo de sensores';

  @override
  String get continuousSensorStreamSubtitle =>
      'Continuar a receber dados dos sensores em tempo real';

  @override
  String get temperatureUnit => 'Unidade de temperatura';

  @override
  String get temperatureUnitSubtitle => 'Mostrar a temperatura em °F';

  @override
  String get pressure => 'Pressão';

  @override
  String get temperature => 'Temperatura';

  @override
  String get rssi => 'RSSI';

  @override
  String get stale => 'Desatualizado';

  @override
  String get weak => 'Fraco';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get networkRequestFailed => 'O pedido de rede falhou';

  @override
  String get resourceNotFound => 'Recurso não encontrado';

  @override
  String get unexpectedError => 'Erro inesperado';

  @override
  String get tireSense => 'TireSense';
}
