// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import '../server_share/camo_server_share.dart';

// ---------------------------------------------------------------------------
// CAMO Authorized Decode Material
// ---------------------------------------------------------------------------

final class CamoAuthorizedDecodeMaterial {
  CamoAuthorizedDecodeMaterial({
    required this.operationId,
    required this.messageId,
    required this.pairingId,
    required this.authorizationId,
    required this.challengeId,
    required this.serverTime,
    required this.serverShare,
    required Uint8List deviceSharedSecret,
    required Uint8List salt,
  }) : deviceSharedSecret = Uint8List.fromList(deviceSharedSecret),
       salt = Uint8List.fromList(salt);

  final String operationId;
  final String messageId;
  final String pairingId;
  final String authorizationId;
  final String challengeId;
  final DateTime serverTime;
  final CamoServerShare serverShare;
  final Uint8List deviceSharedSecret;
  final Uint8List salt;

  bool get isValid {
    return operationId.trim().isNotEmpty &&
        messageId.trim().isNotEmpty &&
        pairingId.trim().isNotEmpty &&
        authorizationId.trim().isNotEmpty &&
        challengeId.trim().isNotEmpty &&
        deviceSharedSecret.isNotEmpty &&
        salt.isNotEmpty &&
        serverShare.operationId == operationId;
  }
}
