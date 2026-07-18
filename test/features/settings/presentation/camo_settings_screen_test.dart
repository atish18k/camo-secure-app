import 'package:camo/app/routes.dart';
import 'package:camo/features/settings/presentation/screens/camo_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('settings shell is honest and recovery remains unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const CamoSettingsScreen(),
        routes: {
          AppRoutes.myIdentity: (_) =>
              const Scaffold(body: Text('Identity destination')),
          AppRoutes.recoverySetup: (_) =>
              const Scaffold(body: Text('Recovery destination')),
        },
      ),
    );
    expect(find.text('Profile, Backup and Settings'), findsOneWidget);
    expect(find.text('Backup provider'), findsOneWidget);
    expect(find.text('Not connected'), findsOneWidget);
    expect(find.text('Restore'), findsOneWidget);
    expect(find.text('Unavailable'), findsOneWidget);
    expect(find.text('Secret export'), findsOneWidget);
    expect(find.text('Prohibited'), findsOneWidget);
    final FilledButton button = tester.widget(
      find.widgetWithText(FilledButton, 'Encrypted restore unavailable'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('settings reuses canonical identity and recovery routes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const CamoSettingsScreen(),
        routes: {
          AppRoutes.myIdentity: (_) =>
              const Scaffold(body: Text('Identity destination')),
          AppRoutes.recoverySetup: (_) =>
              const Scaffold(body: Text('Recovery destination')),
        },
      ),
    );
    await tester.tap(find.text('Open My Identity'));
    await tester.pumpAndSettle();
    expect(find.text('Identity destination'), findsOneWidget);
  });
}
