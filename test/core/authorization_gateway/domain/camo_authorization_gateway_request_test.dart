// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_challenge.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_gateway_request.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_nonce.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_timestamp.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('valid gateway request exposes valid state', () {
    final DateTime now = DateTime.now();
    final CamoAuthorizationGatewayRequest request =
        CamoAuthorizationGatewayRequest(
          requestId: 'request-001',
          authorizationRequest: CamoEnterpriseAuthorizationRequest(
            operationId: 'operation-001',
            userId: 'user-001',
            deviceId: 'device-001',
            operationType: CamoOperationType.encode,
            keyPurpose: CamoKeyPurpose.messageEncryption,
            keyScope: CamoKeyScope.message,
            requestedAt: now,
            requiredEntitlements: const <CamoEntitlementType>{
              CamoEntitlementType.baseEncoding,
            },
            messageId: 'message-001',
          ),
          challenge: CamoAuthorizationChallenge(
            challengeId: 'challenge-001',
            challenge: 'challenge-value',
            issuedAt: now,
            expiresAt: now.add(const Duration(seconds: 30)),
          ),
          nonce: CamoAuthorizationNonce(value: 'nonce-001', createdAt: now),
          timestamp: CamoAuthorizationTimestamp(
            clientTime: now,
            maximumClockSkew: const Duration(seconds: 30),
          ),
          deviceProof: 'device-proof',
        );
    expect(request.isValid, isTrue);
  });
}
