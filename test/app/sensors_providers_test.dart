import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiresense/app/sensors_providers.dart';

void main() {
  test('watch and request share the same sensor source', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final pending = container
        .read(watchSensorFramesUseCaseProvider)
        .execute()
        .first;
    await container.read(requestSensorFrameUseCaseProvider).execute();
    final frame = await pending;

    expect(frame.readings, isNotEmpty);
  });
}
