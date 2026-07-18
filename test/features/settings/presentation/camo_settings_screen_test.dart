import 'package:camo/features/settings/presentation/screens/camo_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('settings owns only app preferences', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CamoSettingsScreen()));
    expect(find.text('App preferences'), findsOneWidget);
    expect(find.text('Open My Identity'), findsNothing);
    expect(find.text('Backup provider'), findsNothing);
    expect(find.text('Review recovery status'), findsNothing);
  });
}
