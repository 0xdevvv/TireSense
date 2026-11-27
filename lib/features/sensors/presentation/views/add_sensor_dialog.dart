import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiresense/features/sensors/presentation/view_models/sensors_view_model.dart';
import 'package:tiresense/l10n/app_localizations.dart';
import 'package:tiresense/shared/widgets/custom_widgets.dart';

class FindSensorDialog extends ConsumerStatefulWidget {
  const FindSensorDialog({super.key});

  @override
  ConsumerState<FindSensorDialog> createState() => _FindSensorDialogState();
}

class _FindSensorDialogState extends ConsumerState<FindSensorDialog> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final discovered = ref.watch(discoveredSensorProvider);

    return AlertDialog(
      title: Text(l10n.addSensor),
      content: discovered.when(
        loading: () => Row(
        children: [
          CustomWidgets.circularLoading,
          const SizedBox(width: 16),
          Text(l10n.searchingForSensor),
        ]),
        data: (sensorId) => Text(sensorId),
        error: (error, stackTrace) => Text(l10n.noSensorFound),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      actions: [
        if (discovered.asData?.value case final sensorId?)
          FilledButton(
            onPressed: () => Navigator.pop(context, sensorId),
            child: Text(l10n.add),
          ),
        Center(child:TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ))
      ],
    );
  }
}