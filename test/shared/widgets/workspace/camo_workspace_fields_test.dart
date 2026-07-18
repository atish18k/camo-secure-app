import 'package:camo/shared/widgets/workspace/camo_input_field.dart';
import 'package:camo/shared/widgets/workspace/camo_output_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'long input and output remain internally scrollable in bounded panels',
    (tester) async {
      final input = TextEditingController();
      final output = TextEditingController(
        text: List.filled(80, 'output').join('\n'),
      );
      addTearDown(input.dispose);
      addTearDown(output.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 420,
              child: Column(
                children: [
                  Expanded(
                    child: CamoInputField(
                      controller: input,
                      onPasteTap: () {},
                      onClearTap: () {},
                    ),
                  ),
                  Expanded(
                    child: CamoOutputField(
                      controller: output,
                      onCopyTap: () {},
                      onShareTap: () {},
                      onClearTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byType(TextField).first,
        List.filled(80, 'input').join('\n'),
      );
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(CamoInputField),
          matching: find.byType(Scrollable),
        ),
        findsWidgets,
      );
      expect(
        find.descendant(
          of: find.byType(CamoOutputField),
          matching: find.byType(Scrollable),
        ),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
