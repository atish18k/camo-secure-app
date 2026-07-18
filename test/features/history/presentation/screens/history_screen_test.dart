import 'package:camo/features/history/presentation/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows metadata-only CAMO and UNCAMO history tabs', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));

    expect(find.text('CAMO history'), findsOneWidget);
    expect(find.text('Recipient'), findsOneWidget);
    expect(find.text('Revoke'), findsOneWidget);
    expect(
      find.text('Message content is never stored in History.'),
      findsOneWidget,
    );

    await tester.tap(find.text('UNCAMO'));
    await tester.pumpAndSettle();

    expect(find.text('UNCAMO history'), findsOneWidget);
    expect(find.text('Sender'), findsOneWidget);
    expect(find.text('Delete metadata'), findsOneWidget);
    expect(
      find.text('Message content is never stored in History.'),
      findsOneWidget,
    );
  });
}
