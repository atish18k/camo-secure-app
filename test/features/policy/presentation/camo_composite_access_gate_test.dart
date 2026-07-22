import 'package:camo/features/policy/domain/services/camo_post_login_access_verifier.dart';
import 'package:camo/features/policy/presentation/screens/camo_composite_access_gate.dart';
import 'package:camo/features/subscription/presentation/screens/choose_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class V implements CamoPostLoginAccessVerifier {
  V(this.value);
  final CamoPostLoginAccessDecision value;
  @override
  Future<CamoPostLoginAccessDecision> verify() async => value;
}

void main() {
  testWidgets(
    'composite gate fails closed and permits only explicit server decision',
    (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: CamoCompositeAccessGate(
            verifier: V(const CamoPostLoginAccessDecision.deny('missing')),
            child: const Text('workspace'),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.byType(ChoosePlanScreen), findsOneWidget);
      expect(find.text('Request commercial access'), findsOneWidget);
      expect(find.text('workspace'), findsNothing);
      await t.pumpWidget(
        MaterialApp(
          home: CamoCompositeAccessGate(
            verifier: V(const CamoPostLoginAccessDecision.allow()),
            child: const Text('workspace'),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('workspace'), findsOneWidget);
    },
  );
}
