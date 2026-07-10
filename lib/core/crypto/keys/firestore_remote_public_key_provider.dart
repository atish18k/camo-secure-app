// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'camo_remote_device_resolver.dart';
import 'camo_remote_public_key_provider.dart';

// ---------------------------------------------------------------------------
// Firestore Remote Public Key Provider
// ---------------------------------------------------------------------------

/// Provides the trusted X25519 public key belonging to the selected active
/// device of a remote CAMO user.
///
/// Device selection and trust validation remain delegated to
/// [CamoRemoteDeviceResolver]. This provider is responsible only for
/// validating and decoding the selected device's public key.
///
/// Security guarantees:
///
/// - uses Device Registry state rather than legacy profile crypto metadata
/// - accepts active trusted devices selected by the resolver only
/// - validates Base64 encoding
/// - validates the X25519 public-key length
/// - never exposes private keys, shared secrets or derived encryption keys
/// - fails closed when trusted key material is missing or malformed
class FirestoreRemotePublicKeyProvider implements CamoRemotePublicKeyProvider {
  const FirestoreRemotePublicKeyProvider(this._remoteDeviceResolver);

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const int _x25519PublicKeyLength = 32;

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final CamoRemoteDeviceResolver _remoteDeviceResolver;

  // ---------------------------------------------------------------------------
  // Get Public Key
  // ---------------------------------------------------------------------------

  @override
  Future<Uint8List> getPublicKey({required String remoteUserId}) async {
    final String normalizedUserId = remoteUserId.trim();

    if (normalizedUserId.isEmpty) {
      throw StateError('Remote user identifier is required.');
    }

    final device = await _remoteDeviceResolver.resolveDevice(
      remoteUserId: normalizedUserId,
    );

    final String encodedPublicKey = device.publicKey.trim();

    if (encodedPublicKey.isEmpty) {
      throw StateError('Remote device public key is unavailable.');
    }

    final Uint8List publicKey;

    try {
      publicKey = Uint8List.fromList(base64Decode(encodedPublicKey));
    } on FormatException catch (error) {
      throw StateError(
        'Remote device public key has invalid Base64 encoding: $error',
      );
    }

    if (publicKey.length != _x25519PublicKeyLength) {
      throw StateError(
        'Remote device public key has an invalid X25519 length.',
      );
    }

    return publicKey;
  }
}
