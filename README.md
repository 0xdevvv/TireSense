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

Each layer only talks to the one below it. Views call view models, view models call use cases, use cases call repository interfaces, and the repository implementations talk to the data sources.

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

State is held in Riverpod. `sensorsViewModelProvider` owns the `SensorPageState`: the sensor map, whether a stream is running, the action button, and the temperature unit. The page selects only `sensorIds`, so it rebuilds when a sensor is added or removed. Each `SensorCard` watches `sensorProvider(id)`, a family provider that selects that one sensor. A new serial number or a new reading rebuilds that card. The other cards stay as they are. The temperature unit is a separate `select` on the same state, so changing °C to °F rebuilds the cards without treating it as a new sensor frame.

`SettingsViewModel` is watched only by `SettingsPage`. Returning from that page calls `updateState()` on the sensors view model, which reloads the saved settings.

## Project layout

```text
main.dart
l10n
test
integration_test
app
├── sensors_providers
└── network_providers
core
├── usecase
├── result
└── network
shared
├── layout
├── theme
└── widgets
features
├── sensors
│   ├── data
│   │   ├── datasources
│   │   │   ├── ble
│   │   │   └── sensor
│   │   ├── dto
│   │   └── repositories
│   ├── domain
│   │   ├── models
│   │   ├── repositories
│   │   ├── usecases
│   │   └── exceptions
│   └── presentation
│       ├── views
│       ├── view_models
│       ├── states
│       ├── widgets
│       └── helpers
└── settings
    ├── data
    │   └── repositories
    ├── domain
    │   ├── models
    │   ├── repositories
    │   └── usecases
    └── presentation
        ├── views
        ├── view_models
        └── helpers
```

## Assumptions

- Readings arrive as frames. A frame may omit a sensor that was present before. The missing sensor stays on screen and is marked stale.
- The domain temperature is always Celsius. Fahrenheit is applied when the card formats the value.
- A serial number is requested when the sensor first appears and again after a failure. A successful serial number is not requested again.
- The simulated BLE source starts with `SENSOR_001` through `SENSOR_004`.
- The mock serial-number API knows `SENSOR_001` through `SENSOR_010`. Any other id is a 404.
- About one in five serial-number requests fails with a 503, so the error and retry states are visible without a real network.
- Adding a sensor is capped at 7. The cap is a use case rule. The repository only stores the sensor.
- The device language selects English or Portuguese. The English label of the update button is exactly "Simulate Sensor Update".

## Limitations

- There is no physical BLE device and no real server. Both boundaries are mocks behind the repository interfaces.

## Possible improvements

- Add a way to remove a sensor. The list only grows, up to the use case limit. A remove action would drop that id from the simulated source and from the page state.
- Replace the manual `Navigator.push` with `go_router`, so Settings and the find-sensor flow are routes instead of calls made inside the page.
- Add a small log of frames, serial-number failures and setting changes. Today those events only update the screen, so a failed request is visible on the card and nowhere else.
  
## Tests

```bash
flutter test
flutter test integration_test
```

`flutter test` runs the unit and widget tests. The integration test boots `main`, checks the dashboard, switches the temperature unit to °F, and checks that the same card shows the converted value.
