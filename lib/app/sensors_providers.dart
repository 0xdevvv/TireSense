import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiresense/app/network_providers.dart';
import 'package:tiresense/features/sensors/data/datasources/ble/api/ble_sensor_data_source.dart';
import 'package:tiresense/features/sensors/data/datasources/ble/mock/simulated_ble_data_source.dart';
import 'package:tiresense/features/sensors/data/datasources/sensor/api/sensor_api.dart';
import 'package:tiresense/features/sensors/data/datasources/sensor/impl/sensor_api_impl.dart';
import 'package:tiresense/features/sensors/data/repositories/sensor_repository_impl.dart';
import 'package:tiresense/features/sensors/data/repositories/serial_number_repository_impl.dart';
import 'package:tiresense/features/sensors/domain/repositories/sensor_repository.dart';
import 'package:tiresense/features/sensors/domain/repositories/serial_number_repository.dart';
import 'package:tiresense/features/sensors/domain/usecases/add_sensor_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/find_sensor_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/get_serial_number_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/request_sensor_frame_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/set_continuous_sensor_stream_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/watch_sensor_frames_use_case.dart';
import 'package:tiresense/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:tiresense/features/settings/domain/repositories/settings_repository.dart';
import 'package:tiresense/features/settings/domain/usecases/load_settings_use_case.dart';
import 'package:tiresense/features/settings/domain/usecases/save_settings_use_case.dart';


// Datasources

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences is created in main')
);

final sensorApiProvider = Provider<SensorApi>(
  (ref) => SensorApiImpl(ref.watch(httpClientProvider))
);

final bleSensorDataSourceProvider = Provider<BleSensorDataSource>(
  (ref) {
    final source = SimulatedBleDataSource();
    ref.onDispose(source.dispose);
    return source;
  },
);

// Repositories

final serialNumberRepositoryProvider = Provider<SerialNumberRepository>(
  (ref) => SerialNumberRepositoryImpl(ref.watch(sensorApiProvider))
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(sharedPreferencesProvider))
);

final sensorRepositoryProvider = Provider<SensorRepository>(
  (ref) => SensorRepositoryImpl(ref.watch(bleSensorDataSourceProvider))
);

// Use Cases

final getSerialNumberUseCaseProvider = Provider(
  (ref) => GetSerialNumberUseCase(ref.watch(serialNumberRepositoryProvider))
);

final watchSensorFramesUseCaseProvider = Provider(
  (ref) => WatchSensorFramesUseCase(ref.watch(sensorRepositoryProvider))
);

final requestSensorFrameUseCaseProvider = Provider(
  (ref) => RequestSensorFrameUseCase(ref.watch(sensorRepositoryProvider))
);

final setContinuousSensorStreamUseCaseProvider = Provider(
  (ref) => SetContinuousSensorStreamUseCase(ref.watch(sensorRepositoryProvider))
);

final saveSettingsUseCaseProvider = Provider(
  (ref) => SaveSettingsUseCase(ref.watch(settingsRepositoryProvider))
);

final loadSettingsUseCaseProvider = Provider(
  (ref) => LoadSettingsUseCase(ref.watch(settingsRepositoryProvider))
);

final addSensorUseCaseProvider = Provider(
  (ref) => AddSensorUseCase(ref.watch(sensorRepositoryProvider))
);

final findSensorUseCaseProvider = Provider(
  (ref) => FindSensorUseCase(ref.watch(sensorRepositoryProvider))
);