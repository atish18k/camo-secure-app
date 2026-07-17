import 'package:camo/shared/widgets/identity/camo_identity_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('identity panel exposes reveal copy and QR controls', (
    WidgetTester tester,
  ) async {
    var reveal = 0;
    var copy = 0;
    var qr = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CamoIdentityPanel(
            camoId: 'CM-ABCD-1234',
            isVisible: false,
            isPaired: true,
            onVisibilityTap: () => reveal++,
            onCopyTap: () => copy++,
            onQrTap: () => qr++,
          ),
        ),
      ),
    );
    expect(find.text('CM-XXXX-XXXX'), findsOneWidget);
    expect(find.text('Paired'), findsOneWidget);
    await tester.tap(find.byTooltip('Reveal CAMO ID'));
    await tester.tap(find.byTooltip('Copy CAMO ID'));
    await tester.tap(find.byTooltip('Show Identity QR'));
    expect((reveal, copy, qr), (1, 1, 1));
  });
}
