// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/authorization/domain/entities/camo_enterprise_authorization_request.dart';
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_request.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('valid operation request exposes valid state', () {
    final CamoEnterpriseOperationRequest request =
        CamoEnterpriseOperationRequest(
          requestId: 'request-001',
          authorizationRequest: CamoEnterpriseAuthorizationRequest(
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
            messageId: 'message-001',
          ),
          createdAt: DateTime.now(),
        );
    expect(request.isValid, isTrue);
  });
}
