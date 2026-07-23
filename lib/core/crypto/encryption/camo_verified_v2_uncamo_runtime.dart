// ignore_for_file: prefer_initializing_formals

import '../../authorization_gateway/data/models/camo_verified_signed_permit_projection_v2.dart';
import '../../authorization_gateway/domain/repositories/camo_verified_v2_permit_store.dart';
import 'camo_authorized_decode_material.dart';
import 'camo_decode_key_material.dart';
import 'camo_decode_key_material_provider.dart';
import 'camo_standard_uncamo_decryptor.dart';

final class CamoVerifiedV2UncamoRuntime {
  const CamoVerifiedV2UncamoRuntime({
    required CamoVerifiedV2PermitStore permitStore,
    required CamoDecodeKeyMaterialProvider keyMaterialProvider,
    required CamoStandardUncamoDecryptor decryptor,
    required DateTime Function() clock,
  }) : _permitStore = permitStore,
       _keyMaterialProvider = keyMaterialProvider,
       _decryptor = decryptor,
       _clock = clock;

  final CamoVerifiedV2PermitStore _permitStore;
  final CamoDecodeKeyMaterialProvider _keyMaterialProvider;
  final CamoStandardUncamoDecryptor _decryptor;
  final DateTime Function() _clock;

  Future<String> decrypt({
    required String requestId,
    required String operationId,
    required String messageId,
    required String pairingId,
    required String encodedText,
  }) async {
    final String normalizedRequestId = requestId.trim();
    final String normalizedOperationId = operationId.trim();
    final String normalizedMessageId = messageId.trim();
    final String normalizedPairingId = pairingId.trim();

    if (normalizedRequestId.isEmpty ||
        normalizedOperationId.isEmpty ||
        normalizedMessageId.isEmpty ||
        normalizedPairingId.isEmpty ||
        encodedText.trim().isEmpty) {
      throw StateError('Verified V2 UNCAMO input is invalid.');
    }

    final CamoVerifiedSignedPermitProjectionV2? permit = await _permitStore
        .consume(
          requestId: normalizedRequestId,
          operationId: normalizedOperationId,
        );

    if (permit == null) {
      throw StateError(
        'Verified V2 permit is unavailable or already consumed.',
      );
    }

    if (permit.operationId.trim() != normalizedOperationId) {
      throw StateError('Verified V2 operation binding mismatch.');
    }

    if (permit.messageId.trim() != normalizedMessageId) {
      throw StateError('Verified V2 message binding mismatch.');
    }

    final DateTime serverTime = _clock().toUtc();

    if (!permit.expiresAt.toUtc().isAfter(serverTime)) {
      throw StateError('Verified V2 permit is expired.');
    }

    final CamoDecodeKeyMaterial keyMaterial = await _keyMaterialProvider
        .resolve(pairingId: normalizedPairingId);

    if (!keyMaterial.isValid) {
      throw StateError('Decode key material is invalid.');
    }

    final CamoAuthorizedDecodeMaterial material = CamoAuthorizedDecodeMaterial(
      operationId: normalizedOperationId,
      messageId: normalizedMessageId,
      pairingId: normalizedPairingId,
      authorizationId: permit.authorizationId,
      challengeId: permit.challengeId,
      serverTime: serverTime,
      serverShare: permit.serverShare,
      deviceSharedSecret: keyMaterial.deviceSharedSecret,
      salt: keyMaterial.salt,
    );

    if (!material.isValid) {
      throw StateError('Authorized decode material construction failed.');
    }

    return _decryptor.decrypt(material: material, encodedText: encodedText);
  }
}
