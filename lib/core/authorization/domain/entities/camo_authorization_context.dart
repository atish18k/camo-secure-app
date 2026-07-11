// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_operation_type.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuthorizationContext {
  CamoAuthorizationContext({
    required this.operationId,
    required this.userId,
    required this.deviceId,
    required this.operationType,
    required this.requestedAt,
    this.pairId,
    this.messageId,
    this.entitlement,
    Map<String, String> metadata = const <String, String>{},
  }) : metadata = Map<String, String>.unmodifiable(metadata);
  final String operationId;
  final String userId;
  final String deviceId;
  final CamoOperationType operationType;
  final DateTime requestedAt;
  final String? pairId;
  final String? messageId;
  final String? entitlement;
  final Map<String, String> metadata;
  bool get hasPairContext => pairId != null && pairId!.isNotEmpty;
  bool get hasMessageContext => messageId != null && messageId!.isNotEmpty;
}
