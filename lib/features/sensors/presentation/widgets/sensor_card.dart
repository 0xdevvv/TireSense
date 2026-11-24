import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiresense/core/result/failure.dart';
import 'package:tiresense/features/sensors/presentation/helpers/sensor_limits.dart';
import 'package:tiresense/features/sensors/presentation/states/serial_number_state.dart';
import 'package:tiresense/features/sensors/presentation/view_models/sensors_view_model.dart';
import 'package:tiresense/features/settings/presentation/helpers/temperature_unit_text.dart';
import 'package:tiresense/features/settings/presentation/view_models/settings_view_model.dart';
import 'package:tiresense/l10n/app_localizations.dart';
import 'package:tiresense/shared/widgets/custom_widgets.dart';

class SensorCard extends ConsumerWidget {
  static const _cardElevation = 0.0;
  static const _cardPadding = 16.0;
  static const _cardRadius = 16.0;
  static const _batteryIconSize = 18.0;
  static const _warningIconSize = 24.0;
  static const _pressureAnimation = Duration(milliseconds: 400);

  final String sensorId;

  const SensorCard({super.key, required this.sensorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sensor = ref.watch(sensorProvider(sensorId));
    final settings = ref.watch(settingsViewModelProvider);
    
    if (sensor == null) {
      return const SizedBox.shrink();
    }

    final reading = sensor.reading;
    final serialNumber = sensor.serialNumber;
    final stale = sensor.isStale;

    final sensorColor = SensorLimits.rssiColor(reading.rssi, theme, stale: stale);
    final batteryLevel = BatteryLevel.of(reading.batteryLevel);
    final batteryColor = batteryLevel.color(theme, stale: stale);
    final pressure = SensorLimits.pressureValue(reading.pressure);

    return Card(
      elevation: _cardElevation,
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  reading.id,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (stale) ...[_SensorTag(tag: l10n.stale), const SizedBox(width: 8)],
                if (SensorLimits.isWeakRssi(reading.rssi)) ...[_SensorTag(tag: l10n.weak), const SizedBox(width: 8)],
                Icon(batteryLevel.icon, size: _batteryIconSize, color: batteryColor),
                const SizedBox(width: 4),
                Text(
                  '${reading.batteryLevel}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: batteryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: pressure),
                duration: _pressureAnimation,
                curve: Curves.easeInOut,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    color: sensorColor,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(l10n.pressure, style: theme.textTheme.bodyMedium),
                const Spacer(),
                Text(
                  '${reading.pressure.toStringAsFixed(2)} bar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: sensorColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    value: settings.unit.format(reading.temperature),
                    label: l10n.temperature,
                    color: sensorColor,
                    alignEnd: false,
                  ),
                ),
                Expanded(
                  child: _Metric(
                    value: '${reading.rssi} dBm',
                    label: l10n.rssi,
                    color: sensorColor,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _SerialNumberLine(serialNumber: serialNumber, onRetry: () {
              ref.read(sensorsViewModelProvider.notifier).retrySerialNumber(sensorId);
            }),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool alignEnd;

  const _Metric({
    required this.value,
    required this.label,
    required this.color,
    required this.alignEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _SensorTag extends StatelessWidget {
  static const _borderRadius = 20.0;
  final String tag;

  const _SensorTag({required this.tag});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(tag, style: theme.textTheme.labelSmall),
    );
  }
}

class _SerialNumberLine extends StatelessWidget {
  final SerialNumberState? serialNumber;
  final VoidCallback onRetry;

  const _SerialNumberLine({required this.serialNumber, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return switch (serialNumber) {
      null || SerialNumberLoading() => const Align(
        alignment: Alignment.centerLeft,
        child: CustomWidgets.circularLoading,
      ),
      SerialNumberReady(:final serialNumber) => Text(
        serialNumber,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      SerialNumberFailed(:final failure) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: SensorCard._warningIconSize,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: InkWell(
              onTap: onRetry,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    switch (failure) {
                      NetworkFailure() => l10n.networkRequestFailed,
                      NotFoundFailure() => l10n.resourceNotFound,
                      UnknownFailure() => l10n.unexpectedError,
                    },
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  Text(
                    l10n.retry,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    };
  }
}
