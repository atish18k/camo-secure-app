// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../../../services/secure_storage/secure_storage_service.dart';
import '../../domain/repositories/camo_device_id_generator.dart';
import '../../domain/repositories/camo_device_identity_service.dart';

// ---------------------------------------------------------------------------
// CAMO Device Identity Service Implementation
// ---------------------------------------------------------------------------

/// Secure implementation of the permanent CAMO device identity.
///
/// Security guarantees:
///
/// - Generates a cryptographically secure UUID v4 once.
/// - Persists the identifier in secure storage.
/// - Never uses hardware identifiers.
/// - Survives login/logout.
/// - Changes only after explicit reset or app data removal.
class CamoDeviceIdentityServiceImpl
    implements CamoDeviceIdentityService {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CamoDeviceIdentityServiceImpl(
    this._secureStorageService,
    this._deviceIdGenerator,
  );

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String _deviceIdStorageKey =
      'camo_device_identity_v1';

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final SecureStorageService _secureStorageService;
  final CamoDeviceIdGenerator _deviceIdGenerator;

  // ---------------------------------------------------------------------------
  // Get Device ID
  // ---------------------------------------------------------------------------

  @override
  Future<String> getDeviceId() async {
    final String? existingId =
        await _secureStorageService.read(
      key: _deviceIdStorageKey,
    );

    if (existingId != null &&
        existingId.trim().isNotEmpty) {
      return existingId.trim();
    }

    final String deviceId =
        _deviceIdGenerator.generate();

    await _secureStorageService.write(
      key: _deviceIdStorageKey,
      value: deviceId,
    );

    return deviceId;
  }

  // ---------------------------------------------------------------------------
  // Delete Device ID
  // ---------------------------------------------------------------------------

  @override
  Future<void> deleteDeviceId() {
    return _secureStorageService.delete(
      key: _deviceIdStorageKey,
    );
  }
}
