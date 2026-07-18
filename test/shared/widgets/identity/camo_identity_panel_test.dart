import 'package:camo/shared/widgets/identity/camo_identity_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('identity is a compact horizontal business card', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CamoIdentityPanel(
            camoId: 'CM-1234-5678',
            isVisible: true,
            isPaired: true,
            onVisibilityTap: () {},
            onCopyTap: () {},
            onQrTap: () {},
          ),
        ),
      ),
    );
    final size = tester.getSize(find.byType(CamoIdentityPanel));
    expect(size.width, greaterThan(size.height));
    expect(size.height, lessThan(120));
    expect(find.byTooltip('Show Identity QR'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
