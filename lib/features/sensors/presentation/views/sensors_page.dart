import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiresense/features/sensors/presentation/states/sensor_page_state.dart';
import 'package:tiresense/features/sensors/presentation/view_models/sensors_view_model.dart';
import 'package:tiresense/features/sensors/presentation/views/add_sensor_dialog.dart';
import 'package:tiresense/features/sensors/presentation/widgets/sensor_card.dart';
import 'package:tiresense/l10n/app_localizations.dart';
import 'package:tiresense/shared/layout/page_layout.dart';
import 'package:tiresense/shared/widgets/collapsing_title.dart';

class SensorsPage extends ConsumerStatefulWidget {
  const SensorsPage({super.key});

  @override
  ConsumerState<SensorsPage> createState() => _SensorsPageState();
}

class _SensorsPageState extends ConsumerState<SensorsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(
          ref.read(sensorsViewModelProvider.notifier).requestData(firstFrame: true),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final sensorIds = ref.watch(
      sensorsViewModelProvider.select((state) => state.sensors.sensorIds),
    );
    final hasStreamError = ref.watch(
      sensorsViewModelProvider.select((state) => state.hasStreamError),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final inset = PageLayout.horizontalInset(constraints.maxWidth);

          return CustomScrollView(
            slivers: [
              CollapsingTitleBar(
                l10n.tireSense,
                actions: [
                  IconButton(
                    tooltip: l10n.addSensor,
                    onPressed: _addSensor,
                    icon: const Icon(Icons.add_circle),
                  ),
                  IconButton(
                    tooltip: l10n.settings,
                    onPressed: _openSettings,
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
              if (hasStreamError)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(inset, PageLayout.listTop, inset, 0),
                    child: Text(
                      l10n.unexpectedError,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              if (sensorIds.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    inset, PageLayout.listTop,
                    inset, PageLayout.listBottom,
                  ),
                  sliver: SliverList.separated(
                    itemCount: sensorIds.length,
                    separatorBuilder: (_, _) => const SizedBox(height: PageLayout.cardGap),
                    itemBuilder: (context, index) {
                      return SensorCard(
                        sensorId: sensorIds[index],
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: const _SensorUpdateButton(),
    );
  }

  void _openSettings() {
    Navigator.of(context).pushNamed('/settings').then((_) {
      if (mounted) {
        ref.read(sensorsViewModelProvider.notifier).reloadSettings();
      }
    });
  }

  Future<void> _addSensor() async {
    final id = await showDialog<String>(
      context: context,
      builder: (context) => const FindSensorDialog(),
    );
    
    if (id == null || id.isEmpty || !mounted) return;
    ref.read(sensorsViewModelProvider.notifier).addSensor(id);
    _showSensorAdded();
  }

  void _showSensorAdded() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorScheme.primaryContainer,
        content: Text(
          l10n.sensorAdded,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class _SensorUpdateButton extends ConsumerWidget {
  const _SensorUpdateButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final landscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    
    final action = ref.watch(
      sensorsViewModelProvider.select((state) => state.action),
    );

    return SafeArea(
      left: !landscape,
      right: !landscape,
      bottom: !landscape,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PageLayout.margin,
          PageLayout.buttonTop,
          PageLayout.margin,
          PageLayout.margin,
        ),
        child: Align(
          alignment: Alignment.center,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: PageLayout.maxWidth),
            child: FilledButton(
              onPressed: () {
                unawaited(ref.read(sensorsViewModelProvider.notifier).requestData());
              },
              child: Text(switch (action) {
                SensorButtonAction.simulate => l10n.simulateSensorUpdate,
                SensorButtonAction.start => l10n.startSensorStream,
                SensorButtonAction.stop => l10n.stopSensorStream,
              }),
            ),
          ),
        ),
      ),
    );
  }
}
