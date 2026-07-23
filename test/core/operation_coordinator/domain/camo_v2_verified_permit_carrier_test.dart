import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('authorization decision carries optional verified V2 permit', () {
    final String source = File(
      'lib/core/authorization/domain/entities/'
      'camo_authorization_pipeline_decision.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        "import '../../../authorization_gateway/data/models/"
        "camo_verified_signed_permit_projection_v2.dart';",
      ),
    );
    expect(
      source,
      contains('final CamoVerifiedSignedPermitProjectionV2? verifiedPermitV2;'),
    );
    expect(source, contains('this.verifiedPermitV2,'));
    expect(source, contains('bool get hasVerifiedV2Permit'));
  });

  test('execution context exposes the exact verified V2 permit carrier', () {
    final String source = File(
      'lib/core/operation_coordinator/domain/entities/'
      'camo_enterprise_operation_execution_context.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('CamoVerifiedSignedPermitProjectionV2? get verifiedPermitV2'),
    );
    expect(source, contains('return authorizationDecision.verifiedPermitV2;'));
    expect(source, contains('bool get hasVerifiedV2Permit'));
    expect(
      source,
      contains('return authorizationDecision.hasVerifiedV2Permit;'),
    );
  });

  test('carrier foundation does not weaken permitsOperation', () {
    final String source = File(
      'lib/core/authorization/domain/entities/'
      'camo_authorization_pipeline_decision.dart',
    ).readAsStringSync();

    expect(source, contains('authorizationDecision.permitsOperation'));
    expect(source, contains('riskDecision.permitsOperation'));
    expect(source, contains('commercialDecision.permitsOperation'));
    expect(source, contains('policyDecision.permitsOperation'));
    expect(source, contains('keyReleaseDecision.permitsKeyRelease'));
    expect(source, contains('session.isActive'));
  });
}
