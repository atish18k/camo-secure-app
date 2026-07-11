// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_operation_type.dart';
import 'camo_key_purpose.dart';
import 'camo_key_scope.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoKeyReleaseContext {
  CamoKeyReleaseContext({
    required this.authorizationId,
    required this.operationId,
    required this.userId,
    required this.deviceId,
    required this.operationType,
    required this.keyPurpose,
    required this.keyScope,
    required this.requestedAt,
    this.pairId,
    this.messageId,
    Map<String, String> attributes = const <String, String>{},
  }) : attributes = Map<String, String>.unmodifiable(attributes);
  final String authorizationId;
  final String operationId;
  final String userId;
  final String deviceId;
  final CamoOperationType operationType;
  final CamoKeyPurpose keyPurpose;
  final CamoKeyScope keyScope;
  final DateTime requestedAt;
  final String? pairId;
  final String? messageId;
  final Map<String, String> attributes;
  bool get hasAuthorization {
    return authorizationId.isNotEmpty;
  }

  bool get hasMessageContext {
    return messageId != null && messageId!.isNotEmpty;
  }

  bool get requiresMessageContext {
    return keyScope == CamoKeyScope.message ||
        keyPurpose == CamoKeyPurpose.messageEncryption ||
        keyPurpose == CamoKeyPurpose.messageDecryption;
  }
}
