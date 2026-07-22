import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('commercial denial exposes request entry without exposing workspace', () {
    final String gate = File(
      'lib/features/policy/presentation/screens/camo_composite_access_gate.dart',
    ).readAsStringSync();
    final String routes = File('lib/app/routes.dart').readAsStringSync();

    expect(
      gate,
      contains(
        "import '../../../subscription/presentation/screens/choose_plan_screen.dart';",
      ),
    );
    expect(gate, contains('return const ChoosePlanScreen();'));
    expect(gate, isNot(contains("Text('Commercial access restricted')")));
    expect(gate, contains('return widget.child;'));

    // Operational routes remain protected by the existing composite gate.
    expect(routes, contains('dashboard: (context) => protect('));
    expect(routes, contains('home: (context) => protect('));
    expect(routes, contains('workspace: (context) => protect('));

    // No client-side commercial grant or canonical access write is introduced.
    expect(gate, isNot(contains('FirebaseFirestore')));
    expect(gate, isNot(contains('commercialAccessV2')));
    expect(gate, isNot(contains('licenseStatus')));
    expect(gate, isNot(contains('subscriptionStatus')));
  });
}
