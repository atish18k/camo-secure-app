// ignore_for_file: prefer_initializing_formals

import 'dart:convert';
import 'dart:typed_data';

import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/pairing/domain/entities/pairing_entity.dart';
import '../../../features/pairing/domain/repositories/pairing_repository.dart';
import '../../../features/pairing/security/device_key_manager.dart';
import '../keys/camo_remote_public_key_provider.dart';
import 'camo_decode_key_material.dart';
import 'camo_decode_key_material_provider.dart';
import 'camo_key_agreement.dart';

final class DefaultCamoDecodeKeyMaterialProvider
    implements CamoDecodeKeyMaterialProvider {
  const DefaultCamoDecodeKeyMaterialProvider({
    required AuthRepository authRepository,
    required PairingRepository pairingRepository,
    required DeviceKeyManager deviceKeyManager,
    required CamoRemotePublicKeyProvider remotePublicKeyProvider,
    required CamoKeyAgreement keyAgreement,
  }) : _authRepository = authRepository,
       _pairingRepository = pairingRepository,
       _deviceKeyManager = deviceKeyManager,
       _remotePublicKeyProvider = remotePublicKeyProvider,
       _keyAgreement = keyAgreement;

  final AuthRepository _authRepository;
  final PairingRepository _pairingRepository;
  final DeviceKeyManager _deviceKeyManager;
  final CamoRemotePublicKeyProvider _remotePublicKeyProvider;
  final CamoKeyAgreement _keyAgreement;

  @override
  Future<CamoDecodeKeyMaterial> resolve({required String pairingId}) async {
    final String normalizedPairingId = pairingId.trim();

    if (normalizedPairingId.isEmpty) {
      throw StateError('Pairing identifier is required.');
    }

    final String currentUserId = _authRepository.currentUserId?.trim() ?? '';

    if (!_authRepository.isSignedIn || currentUserId.isEmpty) {
      throw StateError('Authenticated user is required.');
    }

    final PairingEntity? pairing = await _pairingRepository.getPairingById(
      normalizedPairingId,
    );

    if (pairing == null) {
      throw StateError('Pairing not found.');
    }

    if (pairing.status != PairingStatus.accepted) {
      throw StateError('Pairing is not accepted.');
    }

    final String remoteUserId = _resolveRemoteUserId(
      pairing: pairing,
      currentUserId: currentUserId,
    );

    final keyPair = await _deviceKeyManager.loadKeyPair();

    if (keyPair == null ||
        keyPair.privateKey.isEmpty ||
        keyPair.publicKey.isEmpty) {
      throw StateError('Device key pair not found.');
    }

    final Uint8List remotePublicKey = await _remotePublicKeyProvider
        .getPublicKey(remoteUserId: remoteUserId);

    if (remotePublicKey.isEmpty) {
      throw StateError('Remote public key not found.');
    }

    final Uint8List sharedSecret = await _keyAgreement.createSharedSecret(
      privateKey: keyPair.privateKey,
      remotePublicKey: remotePublicKey,
    );

    if (sharedSecret.isEmpty) {
      throw StateError('Device shared secret derivation failed.');
    }

    final Uint8List salt = Uint8List.fromList(utf8.encode(pairing.id.trim()));

    if (salt.isEmpty) {
      throw StateError('Pairing-bound salt is invalid.');
    }

    return CamoDecodeKeyMaterial(deviceSharedSecret: sharedSecret, salt: salt);
  }

  String _resolveRemoteUserId({
    required PairingEntity pairing,
    required String currentUserId,
  }) {
    if (pairing.requesterUid == currentUserId) {
      return pairing.receiverUid.trim();
    }

    if (pairing.receiverUid == currentUserId) {
      return pairing.requesterUid.trim();
    }

    throw StateError('Current user is not part of this pairing.');
  }
}
