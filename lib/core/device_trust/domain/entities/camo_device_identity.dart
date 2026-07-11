// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_device_trust_level.dart';
import 'camo_device_status.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoDeviceIdentity {
  CamoDeviceIdentity({
    required this.deviceId,
    required this.userId,
    required this.platform,
    required this.publicKey,
    required this.status,
    required this.trustLevel,
    required this.registeredAt,
    this.approvedAt,
    this.revokedAt,
    Map<String, String> metadata = const <String, String>{},
  }) : metadata = Map<String, String>.unmodifiable(metadata);
  final String deviceId;
  final String userId;
  final String platform;
  final String publicKey;
  final CamoDeviceStatus status;
  final CamoDeviceTrustLevel trustLevel;
  final DateTime registeredAt;
  final DateTime? approvedAt;
  final DateTime? revokedAt;
  final Map<String, String> metadata;
  bool get permitsSensitiveOperation {
    return status.isApproved && trustLevel.permitsSensitiveOperation;
  }

  bool get isBlocked => status.isBlocked || trustLevel.isBlocked;
}
