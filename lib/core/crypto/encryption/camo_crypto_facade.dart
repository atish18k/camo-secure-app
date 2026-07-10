// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/pairing/domain/entities/pairing_entity.dart';
import '../../../features/pairing/domain/repositories/pairing_repository.dart';
import '../../../features/pairing/security/device_key_manager.dart';
import '../cache/camo_key_cache.dart';
import '../keys/camo_remote_public_key_provider.dart';
import '../trust/camo_local_device_trust_guard.dart';
import 'camo_key_agreement.dart';
import 'camo_key_derivation.dart';
import 'camo_message_crypto_service.dart';

// ---------------------------------------------------------------------------
// CAMO Crypto Facade
// ---------------------------------------------------------------------------

class CamoCryptoFacade {
  CamoCryptoFacade({
    required this.authRepository,
    required this.pairingRepository,
    required this.deviceKeyManager,
    required this.keyAgreement,
    required this.keyDerivation,
    required this.keyCache,
    required this.localDeviceTrustGuard,
    required this.remotePublicKeyProvider,
    required this.messageCryptoService,
  });

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final AuthRepository authRepository;
  final PairingRepository pairingRepository;
  final DeviceKeyManager deviceKeyManager;
  final CamoKeyAgreement keyAgreement;
  final CamoKeyDerivation keyDerivation;
  final CamoKeyCache keyCache;
  final CamoLocalDeviceTrustGuard localDeviceTrustGuard;
  final CamoRemotePublicKeyProvider remotePublicKeyProvider;
  final CamoMessageCryptoService messageCryptoService;

  // ---------------------------------------------------------------------------
  // Cache Binding
  // ---------------------------------------------------------------------------

  /// Binds each cached conversation key to the exact authenticated users and
  /// remote public key from which it was derived.
  final Map<String, String> _conversationKeyBindings = <String, String>{};

  // ---------------------------------------------------------------------------
  // Encode
  // ---------------------------------------------------------------------------

  Future<String> encodeForPair({
    required String pairingId,
    required String plainText,
    String? subject,
    bool camouflageEnabled = false,
  }) async {
    await localDeviceTrustGuard.ensureTrusted();

    final Uint8List key = await _getConversationKey(pairingId);

    return messageCryptoService.encode(
      plainText: plainText,
      key: key,
      subject: subject,
      camouflageEnabled: camouflageEnabled,
    );
  }

  // ---------------------------------------------------------------------------
  // Decode
  // ---------------------------------------------------------------------------

  Future<String> decodeForPair({
    required String pairingId,
    required String encodedText,
  }) async {
    await localDeviceTrustGuard.ensureTrusted();

    final Uint8List key = await _getConversationKey(pairingId);

    return messageCryptoService.decode(encodedText: encodedText, key: key);
  }

  // ---------------------------------------------------------------------------
  // Conversation Key
  // ---------------------------------------------------------------------------

  Future<Uint8List> _getConversationKey(String pairingId) async {
    final String normalizedPairingId = pairingId.trim();

    if (normalizedPairingId.isEmpty) {
      throw StateError('Pairing identifier is required.');
    }

    final String? currentUserIdValue = authRepository.currentUserId;

    final String currentUserId = currentUserIdValue?.trim() ?? '';

    if (currentUserId.isEmpty) {
      _removeCachedConversationKey(normalizedPairingId);

      throw StateError('Authenticated user not found.');
    }

    final PairingEntity? pairing = await pairingRepository.getPairingById(
      normalizedPairingId,
    );

    if (pairing == null) {
      _removeCachedConversationKey(normalizedPairingId);

      throw StateError('Pairing not found.');
    }

    if (pairing.status != PairingStatus.accepted) {
      _removeCachedConversationKey(normalizedPairingId);

      throw StateError('Pairing is not accepted.');
    }

    final String remoteUserId = _resolveRemoteUserId(
      pairing: pairing,
      currentUserId: currentUserId,
    );

    // This call is memory-backed after the initial realtime listener state.
    // It also fails closed immediately when the remote device becomes blocked,
    // revoked, deleted or otherwise unavailable.
    final Uint8List remotePublicKey = await remotePublicKeyProvider
        .getPublicKey(remoteUserId: remoteUserId);

    if (remotePublicKey.isEmpty) {
      _removeCachedConversationKey(normalizedPairingId);

      throw StateError('Remote public key not found.');
    }

    final String cacheBinding = _buildCacheBinding(
      currentUserId: currentUserId,
      remoteUserId: remoteUserId,
      remotePublicKey: remotePublicKey,
    );

    final cachedEntry = keyCache.get(normalizedPairingId);

    final String? existingBinding =
        _conversationKeyBindings[normalizedPairingId];

    if (cachedEntry != null && existingBinding == cacheBinding) {
      return Uint8List.fromList(cachedEntry.key);
    }

    if (cachedEntry != null || existingBinding != null) {
      _removeCachedConversationKey(normalizedPairingId);
    }

    final Uint8List key = await _deriveConversationKey(
      pairing: pairing,
      currentUserId: currentUserId,
      remoteUserId: remoteUserId,
      remotePublicKey: remotePublicKey,
    );

    keyCache.put(pairId: normalizedPairingId, key: key);

    _conversationKeyBindings[normalizedPairingId] = cacheBinding;

    return key;
  }

  // ---------------------------------------------------------------------------
  // Key Derivation
  // ---------------------------------------------------------------------------

  Future<Uint8List> _deriveConversationKey({
    required PairingEntity pairing,
    required String currentUserId,
    required String remoteUserId,
    required Uint8List remotePublicKey,
  }) async {
    final keyPair = await deviceKeyManager.loadKeyPair();

    if (keyPair == null ||
        keyPair.privateKey.isEmpty ||
        keyPair.publicKey.isEmpty) {
      throw StateError('Device key pair not found.');
    }

    final Uint8List sharedSecret = await keyAgreement.createSharedSecret(
      privateKey: keyPair.privateKey,
      remotePublicKey: remotePublicKey,
    );

    return keyDerivation.deriveKey(
      localUserId: currentUserId,
      remoteUserId: remoteUserId,
      sharedSecret: sharedSecret,
      salt: utf8.encode(pairing.id),
    );
  }

  // ---------------------------------------------------------------------------
  // Cache Binding
  // ---------------------------------------------------------------------------

  String _buildCacheBinding({
    required String currentUserId,
    required String remoteUserId,
    required Uint8List remotePublicKey,
  }) {
    return '$currentUserId'
        '|$remoteUserId'
        '|${base64Encode(remotePublicKey)}';
  }

  void _removeCachedConversationKey(String pairingId) {
    keyCache.remove(pairingId);

    _conversationKeyBindings.remove(pairingId);
  }

  // ---------------------------------------------------------------------------
  // Remote User
  // ---------------------------------------------------------------------------

  String _resolveRemoteUserId({
    required PairingEntity pairing,
    required String currentUserId,
  }) {
    if (pairing.requesterUid == currentUserId) {
      return pairing.receiverUid;
    }

    if (pairing.receiverUid == currentUserId) {
      return pairing.requesterUid;
    }

    throw StateError('Current user is not part of this pairing.');
  }
}
