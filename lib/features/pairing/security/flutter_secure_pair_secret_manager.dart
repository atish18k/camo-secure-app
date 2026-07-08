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
  // Constants
  // ---------------------------------------------------------------------------

  static const int pairSecretLength = 32;
  static const String _storagePrefix = 'pair_secret';

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
    return _secureRandom.generateBytes(pairSecretLength);
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
      key: _storageKey(pairingId),
      value: base64Encode(pairSecret),
    );
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  @override
  Future<Uint8List?> loadPairSecret(
    String pairingId,
  ) async {
    final String? value = await _secureStorageService.read(
      key: _storageKey(pairingId),
    );

    if (value == null || value.isEmpty) {
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
      key: _storageKey(pairingId),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _storageKey(String pairingId) {
    return '${_storagePrefix}_$pairingId';
  }
}