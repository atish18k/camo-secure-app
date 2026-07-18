import 'package:camo/features/recovery/presentation/screens/recovery_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('unbound recovery shell remains honest and fail closed', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RecoverySetupScreen()));

    expect(find.text('Recovery setup'), findsOneWidget);
    expect(find.text('Backup service'), findsOneWidget);
    expect(find.text('Cloud provider'), findsOneWidget);
    expect(find.text('Not connected'), findsOneWidget);
    expect(find.text('Recovery verification'), findsOneWidget);
    expect(find.text('Not verified'), findsOneWidget);
    expect(find.text('Recovery approval'), findsOneWidget);
    expect(find.text('Device migration'), findsOneWidget);
    expect(find.text('Encrypted backup unavailable'), findsOneWidget);
    expect(find.text('Device recovery unavailable'), findsOneWidget);

    final FilledButton backupButton = tester.widget(
      find.widgetWithText(FilledButton, 'Encrypted backup unavailable'),
    );
    expect(backupButton.onPressed, isNull);

    final OutlinedButton recoveryButton = tester.widget(
      find.widgetWithText(OutlinedButton, 'Device recovery unavailable'),
    );
    expect(recoveryButton.onPressed, isNull);
  });

  testWidgets('consent acknowledgement never reports backup activation', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RecoverySetupScreen()));

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    final Checkbox checkbox = tester.widget(find.byType(Checkbox));
    expect(checkbox.value, isTrue);
    expect(
      find.text('Consent does not create a backup or activate recovery.'),
      findsOneWidget,
    );
    expect(find.text('Encrypted backup unavailable'), findsOneWidget);
  });
}
