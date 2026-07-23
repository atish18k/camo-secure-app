import 'package:camo/core/authorization_gateway/data/models/camo_signed_authorization_contract_v2.dart';
import 'package:camo/core/authorization_gateway/data/models/camo_verified_signed_permit_projection_v2.dart';
import 'package:camo/core/authorization_gateway/data/repositories/camo_memory_verified_v2_permit_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CamoMemoryVerifiedV2PermitStore', () {
    test('saves and consumes a verified permit exactly once', () async {
      final CamoMemoryVerifiedV2PermitStore store =
          CamoMemoryVerifiedV2PermitStore();
      final CamoVerifiedSignedPermitProjectionV2 permit = _permit();

      await store.save(requestId: 'request-1', permit: permit);

      final CamoVerifiedSignedPermitProjectionV2? first = await store.consume(
        requestId: 'request-1',
        operationId: 'operation-1',
      );
      final CamoVerifiedSignedPermitProjectionV2? second = await store.consume(
        requestId: 'request-1',
        operationId: 'operation-1',
      );

      expect(first, same(permit));
      expect(second, isNull);
    });

    test('operation mismatch does not consume the permit', () async {
      final CamoMemoryVerifiedV2PermitStore store =
          CamoMemoryVerifiedV2PermitStore();
      final CamoVerifiedSignedPermitProjectionV2 permit = _permit();

      await store.save(requestId: 'request-1', permit: permit);

      final CamoVerifiedSignedPermitProjectionV2? mismatch = await store
          .consume(requestId: 'request-1', operationId: 'other-operation');
      final CamoVerifiedSignedPermitProjectionV2? correct = await store.consume(
        requestId: 'request-1',
        operationId: 'operation-1',
      );

      expect(mismatch, isNull);
      expect(correct, same(permit));
    });

    test('duplicate request storage fails closed', () async {
      final CamoMemoryVerifiedV2PermitStore store =
          CamoMemoryVerifiedV2PermitStore();

      await store.save(requestId: 'request-1', permit: _permit());

      await expectLater(
        store.save(requestId: 'request-1', permit: _permit()),
        throwsStateError,
      );
    });

    test('empty request or operation cannot consume a permit', () async {
      final CamoMemoryVerifiedV2PermitStore store =
          CamoMemoryVerifiedV2PermitStore();

      await store.save(requestId: 'request-1', permit: _permit());

      expect(
        await store.consume(requestId: '', operationId: 'operation-1'),
        isNull,
      );
      expect(
        await store.consume(requestId: 'request-1', operationId: ''),
        isNull,
      );

      expect(
        await store.consume(requestId: 'request-1', operationId: 'operation-1'),
        isNotNull,
      );
    });

    test('clear removes all pending permits', () async {
      final CamoMemoryVerifiedV2PermitStore store =
          CamoMemoryVerifiedV2PermitStore();

      await store.save(requestId: 'request-1', permit: _permit());
      await store.clear();

      expect(
        await store.consume(requestId: 'request-1', operationId: 'operation-1'),
        isNull,
      );
    });
  });
}

CamoVerifiedSignedPermitProjectionV2 _permit() {
  return CamoVerifiedSignedPermitProjectionV2.fromVerifiedContract(
    CamoSignedAuthorizationContractV2(
      schemaVersion: 2,
      canonicalizationVersion: 'CAMO_AUTHORIZATION_V2',
      requestId: 'request-1',
      authorized: true,
      authorizationId: 'authorization-1',
      operationId: 'operation-1',
      challengeId: 'challenge-1',
      userId: 'user-1',
      deviceId: 'device-1',
      pairId: 'pair-1',
      messageId: 'message-1',
      payloadDigest: 'payload-digest-1',
      keyReleaseId: 'key-release-1',
      keyReference: 'key-reference-1',
      sessionId: 'session-1',
      serverShareId: 'share-1',
      serverShareVersion: 1,
      serverShareBase64: 'AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8=',
      serverShareExpiresAt: DateTime.utc(2026, 7, 23, 10, 5),
      issuedAt: DateTime.utc(2026, 7, 23, 10),
      expiresAt: DateTime.utc(2026, 7, 23, 10, 5),
      reasonCode: 'authorized',
      signatureAlgorithm: 'EC_SIGN_P256_SHA256',
      signatureEncoding: 'DER_BASE64',
      signingKeyId: 'signing-key-1',
      signature: 'AQ==',
    ),
  );
}
