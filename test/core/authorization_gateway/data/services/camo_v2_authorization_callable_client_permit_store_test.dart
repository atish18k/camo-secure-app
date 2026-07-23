import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('V2 callable client stores only a verified permit projection', () {
    final String source = File(
      'lib/core/authorization_gateway/data/services/'
      'camo_v2_authorization_callable_client.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        'CamoVerifiedSignedPermitProjectionV2.fromVerifiedContract(contract)',
      ),
    );
    expect(source, contains('await store.save('));
    expect(source, contains('requestId: normalizedRequestId'));
    expect(source, contains('permit: permit'));
    expect(
      source.indexOf('await store.save('),
      lessThan(
        source.indexOf(
          'return CamoSuccess<CamoSignedAuthorizationContractV2>(contract)',
        ),
      ),
    );
  });

  test(
    'permit-store failure remains inside the callable fail-closed boundary',
    () {
      final String source = File(
        'lib/core/authorization_gateway/data/services/'
        'camo_v2_authorization_callable_client.dart',
      ).readAsStringSync();

      expect(source, contains('try {'));
      expect(source, contains('await store.save('));
      expect(source, contains('} on Object {'));
      expect(source, contains('v2_authorization_callable_response_rejected'));
    },
  );

  test('DI injects one shared permit store into the V2 callable client', () {
    final String source = File(
      'lib/core/di/injection_container.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('sl.registerLazySingleton<CamoVerifiedV2PermitStore>'),
    );
    expect(source, contains('CamoMemoryVerifiedV2PermitStore.new'));
    expect(source, contains('permitStore: sl()'));
  });

  test('bridge does not activate production or permit the coordinator', () {
    final String source = File(
      'lib/core/di/injection_container.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('FailClosedCamoAuthorizationGatewayCoordinatorPort'),
    );
    expect(
      source,
      contains('FailClosedCamoAuthorizationPipelineDecisionFactory'),
    );
  });
}
