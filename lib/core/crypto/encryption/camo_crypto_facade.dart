// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/pairing/domain/entities/pairing_entity.dart';
import '../../../features/pairing/domain/repositories/pairing_repository.dart';
import '../../../features/pairing/security/device_key_manager.dart';
import '../../../features/profile/domain/entities/user_crypto_entity.dart';
import '../../../features/profile/domain/repositories/profile_repository.dart';
import '../cache/camo_key_cache.dart';
import 'camo_key_agreement.dart';
import 'camo_key_derivation.dart';
import 'camo_message_crypto_service.dart';

// ---------------------------------------------------------------------------
// CAMO Crypto Facade
// ---------------------------------------------------------------------------

class CamoCryptoFacade {
  const CamoCryptoFacade({
    required this.authRepository,
    required this.pairingRepository,
    required this.profileRepository,
    required this.deviceKeyManager,
    required this.keyAgreement,
    required this.keyDerivation,
    required this.keyCache,
    required this.messageCryptoService,
  });

  final AuthRepository authRepository;
  final PairingRepository pairingRepository;
  final ProfileRepository profileRepository;
  final DeviceKeyManager deviceKeyManager;
  final CamoKeyAgreement keyAgreement;
  final CamoKeyDerivation keyDerivation;
  final CamoKeyCache keyCache;
  final CamoMessageCryptoService messageCryptoService;

  Future<String> encodeForPair({
    required String pairingId,
    required String plainText,
    String? subject,
    bool camouflageEnabled = false,
  }) async {
    final Uint8List key = await _getConversationKey(pairingId);

    return messageCryptoService.encode(
      plainText: plainText,
      key: key,
      subject: subject,
      camouflageEnabled: camouflageEnabled,
    );
  }

  Future<String> decodeForPair({
    required String pairingId,
    required String encodedText,
  }) async {
    final Uint8List key = await _getConversationKey(pairingId);

    return messageCryptoService.decode(
      encodedText: encodedText,
      key: key,
    );
  }

  Future<Uint8List> _getConversationKey(
    String pairingId,
  ) async {
    final String? currentUserId = authRepository.currentUserId;

    if (currentUserId == null || currentUserId.isEmpty) {
      throw StateError('Authenticated user not found.');
    }

    final PairingEntity? pairing =
        await pairingRepository.getPairingById(pairingId);

    if (pairing == null) {
      throw StateError('Pairing not found.');
    }

    if (pairing.status != PairingStatus.accepted) {
      keyCache.remove(pairingId);
      throw StateError('Pairing is not accepted.');
    }

    final cachedEntry = keyCache.get(pairingId);

    if (cachedEntry != null) {
      return Uint8List.fromList(cachedEntry.key);
    }

    final Uint8List key = await _deriveConversationKey(
      pairing: pairing,
      currentUserId: currentUserId,
    );

    keyCache.put(
      pairId: pairingId,
      key: key,
    );

    return key;
  }

  Future<Uint8List> _deriveConversationKey({
    required PairingEntity pairing,
    required String currentUserId,
  }) async {
    final String remoteUserId = _resolveRemoteUserId(
      pairing: pairing,
      currentUserId: currentUserId,
    );

    final keyPair = await deviceKeyManager.loadKeyPair();

    if (keyPair == null) {
      throw StateError('Device key pair not found.');
    }

    final UserCryptoEntity? remoteCrypto =
        await profileRepository.getUserCrypto(remoteUserId);

    if (remoteCrypto == null || remoteCrypto.publicKey.isEmpty) {
      throw StateError('Remote public key not found.');
    }

    final Uint8List sharedSecret = await keyAgreement.createSharedSecret(
      privateKey: keyPair.privateKey,
      remotePublicKey: Uint8List.fromList(
        base64Decode(remoteCrypto.publicKey),
      ),
    );

    return keyDerivation.deriveKey(
      localUserId: currentUserId,
      remoteUserId: remoteUserId,
      sharedSecret: sharedSecret,
      salt: utf8.encode(pairing.id),
    );
  }

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