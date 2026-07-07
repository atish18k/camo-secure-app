// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import '../../../core/crypto/encryption/camo_secure_random.dart';
import '../../../services/secure_storage/secure_storage_service.dart';
import 'pair_secret_manager.dart';

// ---------------------------------------------------------------------------
// Flutter Secure Pair Secret Manager
// ---------------------------------------------------------------------------

class FlutterSecurePairSecretManager implements PairSecretManager {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const FlutterSecurePairSecretManager(
    this._secureStorageService,
    this._secureRandom,
  );

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final SecureStorageService _secureStorageService;
  final CamoSecureRandom _secureRandom;

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  @override
  Future<Uint8List> createPairSecret() async {
    return _secureRandom.generateBytes(32);
  }

  // ---------------------------------------------------------------------------
  // Store
  // ---------------------------------------------------------------------------

  @override
  Future<void> savePairSecret({
    required String pairingId,
    required Uint8List pairSecret,
  }) {
    return _secureStorageService.write(
      key: 'pair_secret_$pairingId',
      value: base64Encode(pairSecret),
    );
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
// Read
// ---------------------------------------------------------------------------

@override
Future<Uint8List?> loadPairSecret(
  String pairingId,
) async {
  final String? value = await _secureStorageService.read(
    key: 'pair_secret_$pairingId',
  );

  if (value == null) {
    return null;
  }

  return Uint8List.fromList(
    base64Decode(value),
  );
}

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  @override
Future<void> deletePairSecret(
  String pairingId,
) {
  return _secureStorageService.delete(
    key: 'pair_secret_$pairingId',
  );
}
}