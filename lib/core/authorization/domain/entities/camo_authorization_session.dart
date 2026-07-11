// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'camo_authorization_token.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuthorizationSession {
  const CamoAuthorizationSession({
    required this.sessionId,
    required this.token,
    required this.createdAt,
    required this.expiresAt,
    required this.consumed,
  });
  final String sessionId;
  final CamoAuthorizationToken token;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool consumed;
  bool get isExpired {
    return !DateTime.now().isBefore(expiresAt);
  }

  bool get isActive {
    return sessionId.isNotEmpty && token.isUsable && !consumed && !isExpired;
  }
}
