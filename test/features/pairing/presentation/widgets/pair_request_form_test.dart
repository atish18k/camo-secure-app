import 'package:camo/features/pairing/presentation/widgets/pair_request_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pair request form normalizes and submits a valid CAMO ID', (
    WidgetTester tester,
  ) async {
    String? submitted;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PairRequestForm(
            isLoading: false,
            onSubmit: (String value) => submitted = value,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'cm-abcd-1234');
    await tester.tap(find.text('Send Pair Request'));
    await tester.pump();
    expect(submitted, 'CM-ABCD-1234');
  });
}
