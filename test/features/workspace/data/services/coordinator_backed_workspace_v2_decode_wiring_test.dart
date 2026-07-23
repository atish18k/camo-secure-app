import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('workspace decode uses dedicated verified V2 coordinator seam', () {
    final String source = File(
      'lib/features/workspace/data/services/'
      'coordinator_backed_camo_authorized_workspace_service.dart',
    ).readAsStringSync();

    expect(source, contains('CamoVerifiedV2WorkspaceDecodeCoordinator'));
    expect(source, contains('return coordinator.decode('));
  });

  test('DI wires callable authorization directly to verified V2 runtime', () {
    final String source = File(
      'lib/core/di/injection_container.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        'sl.registerLazySingleton<CamoVerifiedV2WorkspaceDecodeCoordinator>',
      ),
    );
    expect(
      source,
      contains('authorize: sl<CamoV2AuthorizationCallableClient>().authorize'),
    );
    expect(
      source,
      contains('decrypt: sl<CamoVerifiedV2UncamoRuntime>().decrypt'),
    );
    expect(source, contains('verifiedV2DecodeCoordinator: sl()'));
  });

  test(
    'general coordinator and public workspace binding remain fail closed',
    () {
      final String coordinator = File(
        'lib/core/operation_coordinator/domain/services/'
        'default_camo_enterprise_operation_coordinator.dart',
      ).readAsStringSync();
      final String di = File(
        'lib/core/di/injection_container.dart',
      ).readAsStringSync();

      expect(coordinator, contains('releaseWrappedKey'));
      expect(coordinator, contains('consumeSession'));
      expect(coordinator, contains('consumeKeyRelease'));
      expect(di, contains('FailClosedCamoAuthorizedWorkspaceService.new'));
    },
  );
}
