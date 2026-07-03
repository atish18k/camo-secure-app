import 'package:flutter_test/flutter_test.dart';
import 'package:camo/app/app.dart';

void main() {
  testWidgets('CAMO app loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CamoApp());

    expect(find.text('CAMO'), findsOneWidget);
  });
}