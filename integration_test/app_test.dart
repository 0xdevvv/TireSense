import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiresense/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('the dashboard shows the sensors', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    expect(find.text('TireSense'), findsOneWidget);
    expect(find.text('SENSOR_001'), findsOneWidget);
    expect(find.text('Pressure'), findsWidgets);
  });

  testWidgets('switching to fahrenheit shows (value) °F on the dashboard', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    expect(find.textContaining('°C'), findsWidgets);
    final celsiusText = tester.widget<Text>(find.byKey(const ValueKey('temperature')).first).data!;
    final celsius = double.parse(celsiusText.split(' ').first);
    final fahrenheit = (celsius * 9 / 5 + 32).toStringAsFixed(1);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(SwitchListTile, 'Temperature unit'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('TireSense'), findsOneWidget);
    expect(find.textContaining('°C'), findsNothing);
    
    final shown = tester.widget<Text>(find.byKey(const ValueKey('temperature')).first).data;
    expect(shown, '$fahrenheit °F');
  });
}
