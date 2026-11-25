# TireSense

TireSense monitors tire pressure and temperature from a small set of sensors. Sensor frames come from a simulated BLE source. Serial numbers come from a mock HTTP API. Settings are stored on the device.

The app is in English and Portuguese. The system language decides which one is shown.

## Run

```bash
flutter pub get
flutter run
```

On the dashboard, **Simulate Sensor Update** requests one frame. With continuous stream enabled in Settings, the same button starts and stops a live stream. Temperature can be shown in °C or °F. New sensors are discovered from the add button.

## Architecture

Each layer only talks to the one below it. Views call view models, view models call use cases, use cases call repository interfaces, and the repository implementations talk to the data sources. The graph is wired in `lib/app`.

The arrow points from the provider of the data to whoever uses it.

```mermaid
flowchart TB
  subgraph datasources [Data sources]
    SimulatedBleDataSource
    SensorApi
    SharedPreferences
  end

  subgraph repositories [Repositories]
    SensorRepository
    SerialNumberRepository
    SettingsRepository
  end

  subgraph usecases [Use cases]
    WatchSensorFramesUseCase
    RequestSensorFrameUseCase
    SetContinuousSensorStreamUseCase
    GetSerialNumberUseCase
    AddSensorUseCase
    FindSensorUseCase
    LoadSettingsUseCase
    SaveSettingsUseCase
  end

  subgraph viewmodels [View models]
    SensorsViewModel
    SettingsViewModel
  end

  subgraph views [Views]
    SensorsPage
    SensorCard
    FindSensorDialog
    SettingsPage
  end

  SimulatedBleDataSource --> SensorRepository
  SensorApi --> SerialNumberRepository
  SharedPreferences --> SettingsRepository

  SensorRepository --> WatchSensorFramesUseCase
  SensorRepository --> RequestSensorFrameUseCase
  SensorRepository --> SetContinuousSensorStreamUseCase
  SensorRepository --> AddSensorUseCase
  SensorRepository --> FindSensorUseCase
  SerialNumberRepository --> GetSerialNumberUseCase
  SettingsRepository --> LoadSettingsUseCase
  SettingsRepository --> SaveSettingsUseCase

  WatchSensorFramesUseCase --> SensorsViewModel
  RequestSensorFrameUseCase --> SensorsViewModel
  SetContinuousSensorStreamUseCase --> SensorsViewModel
  GetSerialNumberUseCase --> SensorsViewModel
  AddSensorUseCase --> SensorsViewModel
  FindSensorUseCase --> SensorsViewModel
  LoadSettingsUseCase --> SensorsViewModel
  LoadSettingsUseCase --> SettingsViewModel
  SaveSettingsUseCase --> SettingsViewModel

  SensorsViewModel --> SensorsPage
  SensorsViewModel --> SensorCard
  SensorsViewModel --> FindSensorDialog
  SettingsViewModel --> SettingsPage
```

## Tests

```bash
flutter test
flutter test integration_test
```

`flutter test` runs the unit and widget tests. The integration test boots `main`, checks the dashboard, switches the temperature unit to °F, and checks that the same card shows the converted value.
