// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_device_trust_level.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoDeviceTrustDecision {
  const CamoDeviceTrustDecision({
    required this.deviceId,
    required this.trustLevel,
    required this.allowed,
    required this.reasonCode,
    required this.evaluatedAt,
    required this.expiresAt,
  });
  final String deviceId;
  final CamoDeviceTrustLevel trustLevel;
  final bool allowed;
  final String reasonCode;
  final DateTime evaluatedAt;
  final DateTime expiresAt;
  bool get isExpired => !DateTime.now().isBefore(expiresAt);
  bool get permitsOperation {
    return allowed && trustLevel.permitsSensitiveOperation && !isExpired;
  }
}
