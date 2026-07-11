// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_operation_type.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoSecuritySessionValidationContext {
  CamoSecuritySessionValidationContext({
    required this.sessionId,
    required this.userId,
    required this.deviceId,
    required this.operationType,
    required this.validatedAt,
    this.operationId,
    this.authorizationId,
    this.messageId,
    this.pairId,
    Map<String, String> attributes = const <String, String>{},
  }) : attributes = Map<String, String>.unmodifiable(attributes);
  final String sessionId;
  final String userId;
  final String deviceId;
  final CamoOperationType operationType;
  final DateTime validatedAt;
  final String? operationId;
  final String? authorizationId;
  final String? messageId;
  final String? pairId;
  final Map<String, String> attributes;
  bool get isValid {
    return sessionId.isNotEmpty && userId.isNotEmpty && deviceId.isNotEmpty;
  }
}
