import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/authorization_gateway/data/services/fail_closed_camo_authorization_transport.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_challenge.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_gateway_request.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_nonce.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_timestamp.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_transport_request.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FailClosedCamoAuthorizationTransport', () {
    final DateTime now = DateTime.utc(2026, 7, 12, 3, 30);

    CamoAuthorizationTransportRequest createValidRequest() {
      final gatewayRequest = CamoAuthorizationGatewayRequest(
        requestId: 'request-001',
        authorizationRequest: CamoEnterpriseAuthorizationRequest(
          operationId: 'operation-001',
          userId: 'user-001',
          deviceId: 'device-001',
          operationType: CamoOperationType.encode,
          keyPurpose: CamoKeyPurpose.messageEncryption,
          keyScope: CamoKeyScope.operation,
          requestedAt: now,
          requiredEntitlements: const {},
        ),
        challenge: CamoAuthorizationChallenge(
          challengeId: 'challenge-001',
          challenge: 'challenge-value',
          issuedAt: now,
          expiresAt: now.add(const Duration(minutes: 5)),
        ),
        nonce: CamoAuthorizationNonce(value: 'nonce-001', createdAt: now),
        timestamp: CamoAuthorizationTimestamp(
          clientTime: now,
          maximumClockSkew: const Duration(minutes: 5),
        ),
        deviceProof: 'device-proof',
      );

      return CamoAuthorizationTransportRequest(
        gatewayRequest: gatewayRequest,
        payload: const <String, Object?>{'requestId': 'request-001'},
        headers: const <String, String>{'content-type': 'application/json'},
      );
    }

    test('fails closed for valid production transport request', () async {
      const transport = FailClosedCamoAuthorizationTransport();

      final result = await transport.send(createValidRequest());

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull?.code,
        'production_authorization_transport_unavailable',
      );
    });

    test('rejects structurally invalid transport request', () async {
      const transport = FailClosedCamoAuthorizationTransport();

      final validRequest = createValidRequest();

      final invalidRequest = CamoAuthorizationTransportRequest(
        gatewayRequest: validRequest.gatewayRequest,
        payload: const <String, Object?>{},
        headers: const <String, String>{},
      );

      final result = await transport.send(invalidRequest);

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull?.code,
        'invalid_authorization_transport_request',
      );
    });
  });
}
