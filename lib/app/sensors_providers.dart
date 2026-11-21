import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiresense/app/network_providers.dart';
import 'package:tiresense/features/sensors/data/datasources/ble/api/ble_sensor_data_source.dart';
import 'package:tiresense/features/sensors/data/datasources/ble/mock/simulated_ble_data_source.dart';
import 'package:tiresense/features/sensors/data/datasources/sensor/api/sensor_api.dart';
import 'package:tiresense/features/sensors/data/datasources/sensor/impl/sensor_api_impl.dart';
import 'package:tiresense/features/sensors/data/repositories/sensor_repository_impl.dart';
import 'package:tiresense/features/sensors/data/repositories/serial_number_repository_impl.dart';
import 'package:tiresense/features/sensors/domain/repositories/sensor_repository.dart';
import 'package:tiresense/features/sensors/domain/repositories/serial_number_repository.dart';
import 'package:tiresense/features/sensors/domain/usecases/get_serial_number_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/request_sensor_frame_use_case.dart';
import 'package:tiresense/features/sensors/domain/usecases/watch_sensor_frames_use_case.dart';

final sensorApiProvider = Provider<SensorApi>(
  (ref) => SensorApiImpl(ref.watch(httpClientProvider)),
);

final serialNumberRepositoryProvider = Provider<SerialNumberRepository>(
  (ref) => SerialNumberRepositoryImpl(ref.watch(sensorApiProvider)),
);

final getSerialNumberUseCaseProvider = Provider(
  (ref) => GetSerialNumberUseCase(ref.watch(serialNumberRepositoryProvider)),
);

final bleSensorDataSourceProvider = Provider<BleSensorDataSource>(
  (ref) => SimulatedBleDataSource(),
);

final sensorRepositoryProvider = Provider<SensorRepository>(
  (ref) => SensorRepositoryImpl(ref.watch(bleSensorDataSourceProvider)),
);

final watchSensorFramesUseCaseProvider = Provider(
  (ref) => WatchSensorFramesUseCase(ref.watch(sensorRepositoryProvider)),
);

final requestSensorFrameUseCaseProvider = Provider(
  (ref) => RequestSensorFrameUseCase(ref.watch(sensorRepositoryProvider)),
);
