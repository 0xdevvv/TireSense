// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get simulateSensorUpdate => 'Simulate Sensor Update';

  @override
  String get startSensorStream => 'Start Sensor Stream';

  @override
  String get stopSensorStream => 'Stop Sensor Stream';

  @override
  String get addSensor => 'Add sensor';

  @override
  String get add => 'Add';

  @override
  String get cancel => 'Cancel';

  @override
  String get searchingForSensor => 'Searching for a sensor';

  @override
  String get noSensorFound => 'No sensor found';

  @override
  String get sensorAdded => 'Sensor added';

  @override
  String get settings => 'Settings';

  @override
  String get continuousSensorStream => 'Continuous sensor stream';

  @override
  String get continuousSensorStreamSubtitle =>
      'Keep receiving sensor data in real time';

  @override
  String get temperatureUnit => 'Temperature unit';

  @override
  String get temperatureUnitSubtitle => 'Show temperature in °F';

  @override
  String get pressure => 'Pressure';

  @override
  String get temperature => 'Temperature';

  @override
  String get rssi => 'RSSI';

  @override
  String get stale => 'Stale';

  @override
  String get weak => 'Weak';

  @override
  String get retry => 'Retry';

  @override
  String get networkRequestFailed => 'Network request failed';

  @override
  String get resourceNotFound => 'Resource not found';

  @override
  String get unexpectedError => 'Unexpected error';

  @override
  String get tireSense => 'TireSense';
}
