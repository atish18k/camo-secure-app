import 'package:camo/features/workspace/data/services/fail_closed_camo_authorized_workspace_service.dart';
import 'package:camo/features/workspace/domain/services/camo_authorized_workspace_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const CamoAuthorizedWorkspaceService service =
      FailClosedCamoAuthorizedWorkspaceService();

  test('blocks encode without fresh server authorization', () async {
    await expectLater(
      service.encode(pairingId: 'pair-001', plainText: 'secret'),
      throwsA(
        isA<StateError>().having(
          (StateError error) => error.message,
          'message',
          FailClosedCamoAuthorizedWorkspaceService
              .authorizationUnavailableMessage,
        ),
      ),
    );
  });

  test('blocks decode without fresh server authorization', () async {
    await expectLater(
      service.decode(pairingId: 'pair-001', encodedText: 'encoded'),
      throwsA(
        isA<StateError>().having(
          (StateError error) => error.message,
          'message',
          FailClosedCamoAuthorizedWorkspaceService
              .authorizationUnavailableMessage,
        ),
      ),
    );
  });
}
