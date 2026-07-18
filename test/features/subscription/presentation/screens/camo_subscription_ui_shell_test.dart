import 'package:camo/app/routes.dart';
import 'package:camo/core/licensing/domain/entities/camo_license_status.dart';
import 'package:camo/core/licensing/domain/entities/camo_subscription_status.dart';
import 'package:camo/features/subscription/presentation/models/camo_subscription_view_state.dart';
import 'package:camo/features/subscription/presentation/screens/activate_plan_screen.dart';
import 'package:camo/features/subscription/presentation/screens/choose_plan_screen.dart';
import 'package:camo/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('plan review never grants client-side activation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const ChoosePlanScreen(),
        routes: {AppRoutes.planActivation: (_) => const ActivatePlanScreen()},
      ),
    );

    expect(find.text('\u20B9199 / month'), findsOneWidget);
    expect(find.textContaining('does not activate access'), findsOneWidget);

    await tester.tap(find.text('Review activation'));
    await tester.pumpAndSettle();

    expect(find.text('Activation unavailable'), findsOneWidget);
    final FilledButton activation = tester.widget(
      find.widgetWithText(FilledButton, 'Provider verification unavailable'),
    );
    expect(activation.onPressed, isNull);
  });

  testWidgets('unbound subscription state remains fail closed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const SubscriptionScreen(),
        routes: {AppRoutes.choosePlan: (_) => const ChoosePlanScreen()},
      ),
    );

    expect(find.text('Subscription status unavailable'), findsOneWidget);
    expect(find.textContaining('Access remains fail-closed'), findsOneWidget);
    expect(find.text('Active'), findsNothing);

    await tester.tap(find.text('View available plan'));
    await tester.pumpAndSettle();
    expect(find.text('Choose Plan'), findsOneWidget);
    expect(find.textContaining('does not activate access'), findsOneWidget);
  });

  testWidgets('complete server facts render without enabling management', (
    tester,
  ) async {
    final state = CamoSubscriptionViewState.serverVerified(
      planId: 'camo_monthly_inr_199',
      monthlyPriceInr: 199,
      licenseStatus: CamoLicenseStatus.active,
      subscriptionStatus: CamoSubscriptionStatus.active,
      billingState: 'Provider confirmed',
      deviceAllowance: 3,
      renewsAt: DateTime.utc(2026, 8, 18),
    );

    await tester.pumpWidget(
      MaterialApp(home: SubscriptionScreen(state: state)),
    );

    expect(find.text('Active'), findsNWidgets(2));
    expect(find.text('\u20B9199 / month'), findsOneWidget);
    expect(find.text('3 devices'), findsOneWidget);
    expect(find.text('Provider confirmed'), findsOneWidget);
    final FilledButton manage = tester.widget(
      find.widgetWithText(FilledButton, 'Manage subscription unavailable'),
    );
    expect(manage.onPressed, isNull);
  });
}
