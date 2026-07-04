import 'package:camo/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CAMO app loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CamoApp(),
      ),
    );

    
    expect(find.text('CAMO'), findsOneWidget);
  });
}