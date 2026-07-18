import 'package:camo/shared/widgets/workspace/camo_camouflage_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Camouflage remains visibly deferred and disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CamoCamouflageSwitch(value: false, onChanged: null),
        ),
      ),
    );

    expect(find.text('Camouflage (Coming later)'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
  });
}
