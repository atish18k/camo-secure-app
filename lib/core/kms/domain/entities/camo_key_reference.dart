// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'camo_key_purpose.dart';
import 'camo_key_scope.dart';
import 'camo_key_status.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoKeyReference {
  const CamoKeyReference({
    required this.keyId,
    required this.keyVersion,
    required this.provider,
    required this.purpose,
    required this.scope,
    required this.status,
    required this.createdAt,
    this.rotatedAt,
    this.expiresAt,
  });
  final String keyId;
  final String keyVersion;
  final String provider;
  final CamoKeyPurpose purpose;
  final CamoKeyScope scope;
  final CamoKeyStatus status;
  final DateTime createdAt;
  final DateTime? rotatedAt;
  final DateTime? expiresAt;
  bool get isExpired {
    final DateTime? expiry = expiresAt;
    return expiry != null && !DateTime.now().isBefore(expiry);
  }

  bool get isUsable {
    return status.isUsable && !isExpired;
  }
}
