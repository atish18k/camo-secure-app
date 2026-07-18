import 'package:camo/shared/widgets/navigation/camo_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'shows CAMO Mode and UNCAMO Mode while preserving internal tabs',
    (tester) async {
      CamoWorkspaceTab? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CamoTabs(
              selectedTab: CamoWorkspaceTab.encoder,
              onChanged: (tab) => selected = tab,
            ),
          ),
        ),
      );
      expect(find.text('CAMO Mode'), findsOneWidget);
      expect(find.text('UNCAMO Mode'), findsOneWidget);
      expect(find.text('Encoder'), findsNothing);
      expect(find.text('Decoder'), findsNothing);
      await tester.tap(find.text('UNCAMO Mode'));
      expect(selected, CamoWorkspaceTab.decoder);
    },
  );
}
