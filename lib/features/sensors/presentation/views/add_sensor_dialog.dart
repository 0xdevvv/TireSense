import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiresense/features/sensors/presentation/view_models/sensors_view_model.dart';

class FindSensorDialog extends ConsumerStatefulWidget {
  const FindSensorDialog({super.key});

  @override
  ConsumerState<FindSensorDialog> createState() => _FindSensorDialogState();
}

class _FindSensorDialogState extends ConsumerState<FindSensorDialog> {
  @override
  Widget build(BuildContext context) {
    final discovered = ref.watch(discoveredSensorProvider);

    return AlertDialog(
      title: const Text('Add sensor'),
      content: discovered.when(
        loading: () =>  const Row(
        children: [
          SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('Searching for a sensor'),
          ],
        ),
        data: (sensorId) => Text(sensorId),
        error: (error, stackTrace) => Text('No sensor found'),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      actions: [
        if (discovered.asData?.value case final sensorId?)
          FilledButton(
            onPressed: () => Navigator.pop(context, sensorId),
            child: const Text('Add'),
          ),
        Center(child:TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ))
      ],
    );
  }
}