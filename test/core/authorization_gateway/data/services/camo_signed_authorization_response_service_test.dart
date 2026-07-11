import 'package:camo/core/authorization_gateway/data/services/fail_closed_camo_authorization_response_signature_verifier.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_response_signature_payload.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_signature_verification_decision.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime fixedServerTime = DateTime.utc(2026, 7, 12, 0, 30);

  test('valid signature payload produces deterministic canonical text', () {
    final CamoAuthorizationResponseSignaturePayload payload =
        CamoAuthorizationResponseSignaturePayload(
          responseId: 'response-001',
          requestId: 'request-001',
          operationId: 'operation-001',
          sessionId: 'session-001',
          keyReleaseId: 'release-001',
          serverTime: fixedServerTime,
        );

    expect(payload.isValid, isTrue);

    expect(
      payload.toCanonicalString(),
      <String>[
        'responseId=response-001',
        'requestId=request-001',
        'operationId=operation-001',
        'sessionId=session-001',
        'keyReleaseId=release-001',
        'serverTime=2026-07-12T00:30:00.000Z',
      ].join('\n'),
    );
  });

  test('invalid canonical payload fails closed', () {
    final CamoAuthorizationResponseSignaturePayload payload =
        CamoAuthorizationResponseSignaturePayload(
          responseId: '',
          requestId: 'request-001',
          operationId: 'operation-001',
          sessionId: 'session-001',
          keyReleaseId: 'release-001',
          serverTime: fixedServerTime,
        );

    expect(payload.isValid, isFalse);
    expect(payload.toCanonicalString, throwsStateError);
  });

  test('fail-closed verifier rejects a non-empty signature', () async {
    const FailClosedCamoAuthorizationResponseSignatureVerifier verifier =
        FailClosedCamoAuthorizationResponseSignatureVerifier();

    final CamoAuthorizationResponseSignaturePayload payload =
        CamoAuthorizationResponseSignaturePayload(
          responseId: 'response-001',
          requestId: 'request-001',
          operationId: 'operation-001',
          sessionId: 'session-001',
          keyReleaseId: 'release-001',
          serverTime: fixedServerTime,
        );

    final CamoAuthorizationSignatureVerificationDecision decision =
        await verifier.verify(
          payload: payload,
          signature: 'unverified-server-signature',
        );

    expect(decision.permitsResponseUse, isFalse);

    expect(
      decision.reasonCode,
      'production_server_signature_verifier_unavailable',
    );
  });

  test('denied verification decision never permits response use', () {
    const CamoAuthorizationSignatureVerificationDecision decision =
        CamoAuthorizationSignatureVerificationDecision.denied(
          'authorization_response_signature_missing',
        );

    expect(decision.verified, isFalse);
    expect(decision.permitsResponseUse, isFalse);
  });

  test('verified decision permits response use', () {
    const CamoAuthorizationSignatureVerificationDecision decision =
        CamoAuthorizationSignatureVerificationDecision.verified();

    expect(decision.verified, isTrue);
    expect(decision.permitsResponseUse, isTrue);
  });
}
