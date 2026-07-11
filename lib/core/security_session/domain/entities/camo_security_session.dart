// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'camo_security_session_scope.dart';
import 'camo_security_session_status.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoSecuritySession {
  CamoSecuritySession({
    required this.sessionId,
    required this.userId,
    required this.deviceId,
    required this.scope,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    required this.lastValidatedAt,
    required this.singleUse,
    this.operationId,
    this.authorizationId,
    this.messageId,
    this.pairId,
    Map<String, String> attributes = const <String, String>{},
  }) : attributes = Map<String, String>.unmodifiable(attributes);
  final String sessionId;
  final String userId;
  final String deviceId;
  final CamoSecuritySessionScope scope;
  final CamoSecuritySessionStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime lastValidatedAt;
  final bool singleUse;
  final String? operationId;
  final String? authorizationId;
  final String? messageId;
  final String? pairId;
  final Map<String, String> attributes;
  bool get isExpired {
    return !DateTime.now().isBefore(expiresAt);
  }

  bool get hasValidIdentityBinding {
    return userId.isNotEmpty && deviceId.isNotEmpty;
  }

  bool get hasValidOperationBinding {
    if (!scope.isOperationBound) {
      return true;
    }
    return operationId != null && operationId!.isNotEmpty;
  }

  bool get isUsable {
    return sessionId.isNotEmpty &&
        status.isActive &&
        hasValidIdentityBinding &&
        hasValidOperationBinding &&
        !isExpired;
  }
}
