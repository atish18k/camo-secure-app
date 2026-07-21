import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MP-023H registers the complete V2 callable verification graph', () {
    final String source = File(
      'lib/core/di/injection_container.dart',
    ).readAsStringSync();

    for (final String token in <String>[
      'CamoSignedAuthorizationContractV2Canonicalizer',
      'CamoSignedAuthorizationContractV2Verifier',
      'CamoSignedAuthorizationContractV2TransportDecoder',
      'CamoV2AuthorizationCallableClient',
      'verifyContract: sl<CamoSignedAuthorizationContractV2Verifier>().verify',
    ]) {
      expect(source, contains(token), reason: 'Missing V2 DI token: $token');
    }
  });

  test('MP-023H does not remove the retained V1 stack', () {
    final String source = File(
      'lib/core/di/injection_container.dart',
    ).readAsStringSync();

    for (final String token in <String>[
      'CamoSignedAuthorizationContractV1Canonicalizer',
      'CamoSignedAuthorizationContractV1Verifier',
      'CamoSignedAuthorizationContractV1TransportDecoder',
      'CamoAuthorizationCallableClient',
    ]) {
      expect(
        source,
        contains(token),
        reason: 'V1 was removed unexpectedly: $token',
      );
    }
  });

  test('V2 callable client remains schema-specific and fail closed', () {
    final String source = File(
      'lib/core/authorization_gateway/data/services/'
      'camo_v2_authorization_callable_client.dart',
    ).readAsStringSync();

    for (final String token in <String>[
      'CamoV2AuthorizationCallableClient',
      'CamoSignedAuthorizationContractV2',
      'CamoSignedAuthorizationContractV2TransportDecoder',
      'v2_authorization_callable_request_invalid',
      'v2_authorization_callable_response_rejected',
    ]) {
      expect(
        source,
        contains(token),
        reason: 'Missing V2 client token: $token',
      );
    }

    expect(source, isNot(contains('CamoSignedAuthorizationContractV1')));
  });
}
