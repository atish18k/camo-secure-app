import 'package:camo/core/authorization/data/services/default_camo_enterprise_authorization_operation_request_mapper.dart';
import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps valid authorization request into bound operation request', () {
    final DateTime now = DateTime.utc(2026, 7, 13);

    final mapper = DefaultCamoEnterpriseAuthorizationOperationRequestMapper(
      requestIdGenerator: () => 'request-001',
      clock: () => now,
    );

    final request = CamoEnterpriseAuthorizationRequest(
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
      pairId: 'pair-001',
    );

    final result = mapper.map(request);

    expect(result.requestId, 'request-001');
    expect(result.authorizationRequest, same(request));
    expect(result.payloadReference, 'operation-001');
    expect(result.createdAt, now);
    expect(result.metadata['authorizationMode'], 'freshServerAuthorization');
    expect(result.isValid, isTrue);
  });

  test('rejects empty generated request identifier', () {
    final mapper = DefaultCamoEnterpriseAuthorizationOperationRequestMapper(
      requestIdGenerator: () => ' ',
      clock: DateTime.now,
    );

    final request = CamoEnterpriseAuthorizationRequest(
      operationId: 'operation-001',
      userId: 'user-001',
      deviceId: 'device-001',
      operationType: CamoOperationType.encode,
      keyPurpose: CamoKeyPurpose.messageEncryption,
      keyScope: CamoKeyScope.message,
      requestedAt: DateTime.now(),
      requiredEntitlements: const <CamoEntitlementType>{
        CamoEntitlementType.baseEncoding,
      },
    );

    expect(() => mapper.map(request), throwsStateError);
  });
}
