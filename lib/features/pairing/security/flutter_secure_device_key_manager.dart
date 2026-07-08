// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../../core/crypto/encryption/camo_key_pair.dart';
import '../../../services/secure_storage/secure_storage_service.dart';
import 'device_key_manager.dart';

// ---------------------------------------------------------------------------
// Flutter Secure Device Key Manager
// ---------------------------------------------------------------------------

class FlutterSecureDeviceKeyManager implements DeviceKeyManager {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const FlutterSecureDeviceKeyManager(
    this._secureStorageService,
  );

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const String _privateKeyStorageKey = 'device_x25519_private_key';
  static const String _publicKeyStorageKey = 'device_x25519_public_key';

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final SecureStorageService _secureStorageService;

  // ---------------------------------------------------------------------------
  // Exists
  // ---------------------------------------------------------------------------

  @override
  Future<bool> hasKeyPair() async {
    final String? privateKey = await _secureStorageService.read(
      key: _privateKeyStorageKey,
    );

    final String? publicKey = await _secureStorageService.read(
      key: _publicKeyStorageKey,
    );

    return privateKey != null &&
        privateKey.isNotEmpty &&
        publicKey != null &&
        publicKey.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  @override
  Future<CamoKeyPair> createKeyPair() async {
    final X25519 x25519 = X25519();
    final SimpleKeyPair keyPair = await x25519.newKeyPair();

    final List<int> privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    final SimplePublicKey publicKey = await keyPair.extractPublicKey();

    return CamoKeyPair(
      privateKey: Uint8List.fromList(privateKeyBytes),
      publicKey: Uint8List.fromList(publicKey.bytes),
    );
  }

  // ---------------------------------------------------------------------------
  // Store
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveKeyPair(
    CamoKeyPair keyPair,
  ) async {
    await _secureStorageService.write(
      key: _privateKeyStorageKey,
      value: base64Encode(keyPair.privateKey),
    );

    await _secureStorageService.write(
      key: _publicKeyStorageKey,
      value: base64Encode(keyPair.publicKey),
    );
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  @override
  Future<CamoKeyPair?> loadKeyPair() async {
    final String? privateKeyValue = await _secureStorageService.read(
      key: _privateKeyStorageKey,
    );

    final String? publicKeyValue = await _secureStorageService.read(
      key: _publicKeyStorageKey,
    );

    if (privateKeyValue == null ||
        privateKeyValue.isEmpty ||
        publicKeyValue == null ||
        publicKeyValue.isEmpty) {
      return null;
    }

    return CamoKeyPair(
      privateKey: Uint8List.fromList(
        base64Decode(privateKeyValue),
      ),
      publicKey: Uint8List.fromList(
        base64Decode(publicKeyValue),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  @override
  Future<void> deleteKeyPair() async {
    await _secureStorageService.delete(
      key: _privateKeyStorageKey,
    );

    await _secureStorageService.delete(
      key: _publicKeyStorageKey,
    );
  }
}