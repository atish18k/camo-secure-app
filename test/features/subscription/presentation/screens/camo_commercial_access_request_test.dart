import 'package:camo/features/subscription/domain/repositories/camo_commercial_access_request_repository.dart';
import 'package:camo/features/subscription/presentation/screens/choose_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeRequestRepository
    implements CamoCommercialAccessRequestRepository {
  int calls = 0;
  Object? error;

  @override
  Future<CamoCommercialAccessRequestResult> requestAccess() async {
    calls++;
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    return const CamoCommercialAccessRequestResult(
      requestId: 'user-1',
      status: 'pending',
    );
  }
}

void main() {
  testWidgets('ordinary user can submit one server-authorized request', (
    tester,
  ) async {
    final repository = _FakeRequestRepository();

    await tester.pumpWidget(
      MaterialApp(home: ChoosePlanScreen(requestRepository: repository)),
    );

    expect(find.text('Request commercial access'), findsOneWidget);
    expect(find.textContaining('does not activate access'), findsOneWidget);

    await tester.tap(find.text('Request commercial access'));
    await tester.pumpAndSettle();

    expect(repository.calls, 1);
    expect(find.text('Request pending'), findsOneWidget);
    expect(
      find.text(
        'Commercial access request submitted for administrator review.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Request pending'));
    await tester.pump();
    expect(repository.calls, 1);
  });

  testWidgets('request failure remains fail closed and retryable', (
    tester,
  ) async {
    final repository = _FakeRequestRepository()
      ..error = StateError('network unavailable');

    await tester.pumpWidget(
      MaterialApp(home: ChoosePlanScreen(requestRepository: repository)),
    );

    await tester.tap(find.text('Request commercial access'));
    await tester.pumpAndSettle();

    expect(repository.calls, 1);
    expect(find.text('Request commercial access'), findsOneWidget);
    expect(
      find.text(
        'Unable to submit the commercial access request. Please retry.',
      ),
      findsOneWidget,
    );
  });
}
