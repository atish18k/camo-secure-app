// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../kms/domain/entities/camo_key_purpose.dart';
import '../../../kms/domain/entities/camo_key_scope.dart';
import '../../../licensing/domain/entities/camo_entitlement_type.dart';
import '../../../shared/types/camo_operation_type.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoEnterpriseAuthorizationRequest {
  CamoEnterpriseAuthorizationRequest({
    required this.operationId,
    required this.userId,
    required this.deviceId,
    required this.operationType,
    required this.keyPurpose,
    required this.keyScope,
    required this.requestedAt,
    required Set<CamoEntitlementType> requiredEntitlements,
    this.pairId,
    this.messageId,
    Map<String, String> attributes = const <String, String>{},
  }) : requiredEntitlements = Set<CamoEntitlementType>.unmodifiable(
         requiredEntitlements,
       ),
       attributes = Map<String, String>.unmodifiable(attributes);
  final String operationId;
  final String userId;
  final String deviceId;
  final CamoOperationType operationType;
  final CamoKeyPurpose keyPurpose;
  final CamoKeyScope keyScope;
  final DateTime requestedAt;
  final Set<CamoEntitlementType> requiredEntitlements;
  final String? pairId;
  final String? messageId;
  final Map<String, String> attributes;
  bool get isValid {
    return operationId.isNotEmpty && userId.isNotEmpty && deviceId.isNotEmpty;
  }
}
