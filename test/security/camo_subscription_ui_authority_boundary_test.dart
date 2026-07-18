import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('subscription routes are exact-device protected and drawer-bound', () {
    final routes = File('lib/app/routes.dart').readAsStringSync();
    final workspace = File(
      'lib/features/workspace/presentation/screens/workspace_screen.dart',
    ).readAsStringSync();
    final drawer = File(
      'lib/shared/widgets/navigation/camo_drawer.dart',
    ).readAsStringSync();

    expect(routes, contains('protect(const ChoosePlanScreen())'));
    expect(routes, contains('protect(const ActivatePlanScreen())'));
    expect(routes, contains('protect(const SubscriptionScreen())'));
    expect(workspace, contains('onSubscriptionTap: _openSubscription'));
    expect(
      workspace,
      contains('Navigator.pushNamed(context, AppRoutes.subscription)'),
    );
    expect(drawer, contains("title: 'Subscription'"));
  });

  test('UI shell contains no client-authoritative commercial writes', () {
    final files = <String>[
      'lib/features/subscription/presentation/screens/choose_plan_screen.dart',
      'lib/features/subscription/presentation/screens/activate_plan_screen.dart',
      'lib/features/subscription/presentation/screens/subscription_screen.dart',
      'lib/features/subscription/presentation/models/camo_subscription_view_state.dart',
    ];
    final source = files.map((path) => File(path).readAsStringSync()).join();

    expect(source, isNot(contains('FirebaseFirestore')));
    expect(source, isNot(contains('subscriptionActive')));
    expect(source, isNot(contains('grantedEntitlements')));
    expect(source, isNot(contains('.set(')));
    expect(source, isNot(contains('.update(')));
    expect(source, contains('onPressed: null'));
  });
}
