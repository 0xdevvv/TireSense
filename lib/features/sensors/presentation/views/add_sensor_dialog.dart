import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiresense/features/sensors/presentation/view_models/sensors_view_model.dart';

class FindSensorDialog extends ConsumerStatefulWidget {
  const FindSensorDialog({super.key});

  @override
  ConsumerState<FindSensorDialog> createState() => _FindSensorDialogState();
}

class _FindSensorDialogState extends ConsumerState<FindSensorDialog> {
  String? _sensorId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _search());
  }

  Future<void> _search() async {
    final id = await ref.read(sensorsViewModelProvider.notifier).findSensor();
    
    if (mounted) {
      setState(() => _sensorId = id); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final found = _sensorId != null;

    final cancelButton = Center(child:TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancel'),
    ));

    return AlertDialog(
      title: const Text('Add sensor'),
      content: _content(),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      actions: [
        if (found)
          FilledButton(
            onPressed: () => Navigator.pop(context, _sensorId),
            child: const Text('Add'),
          ),
        cancelButton
      ],
    );
  }

  Widget _content() {
    if (_sensorId == null) {
      return const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 16),
          Text('Searching for a sensor'),
        ],
      );
    }
    return Text(_sensorId!);
  }
}
