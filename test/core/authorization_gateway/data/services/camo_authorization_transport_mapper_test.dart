import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/authorization_gateway/data/services/default_camo_authorization_transport_mapper.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_challenge.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_gateway_request.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_nonce.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_timestamp.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultCamoAuthorizationTransportMapper', () {
    test('maps valid gateway request to bound transport request', () {
      const mapper = DefaultCamoAuthorizationTransportMapper();

      final DateTime now = DateTime.utc(2026, 7, 12, 3, 30);

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
          pairId: 'pair-001',
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

      final transportRequest = mapper.mapRequest(gatewayRequest);

      expect(transportRequest.isValid, isTrue);
      expect(transportRequest.payload['requestId'], 'request-001');
      expect(transportRequest.payload['operationId'], 'operation-001');
      expect(transportRequest.payload['deviceId'], 'device-001');
      expect(transportRequest.headers['x-camo-request-id'], 'request-001');
      expect(transportRequest.headers['x-camo-operation-id'], 'operation-001');
    });

    test('rejects invalid gateway request', () {
      const mapper = DefaultCamoAuthorizationTransportMapper();

      final DateTime now = DateTime.utc(2026, 7, 12, 3, 30);

      final invalidRequest = CamoAuthorizationGatewayRequest(
        requestId: '',
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

      expect(() => mapper.mapRequest(invalidRequest), throwsStateError);
    });
  });
}
