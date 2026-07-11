import 'package:camo/core/crypto/encryption/camo_crypto_facade.dart';

import '../../domain/services/camo_workspace_crypto_port.dart';

final class CamoCryptoFacadeWorkspacePort implements CamoWorkspaceCryptoPort {
  const CamoCryptoFacadeWorkspacePort(this._cryptoFacade);

  final CamoCryptoFacade _cryptoFacade;

  @override
  Future<String> encode({
    required String pairingId,
    required String plainText,
    String? subject,
    bool camouflageEnabled = false,
  }) {
    return _cryptoFacade.encodeForPair(
      pairingId: pairingId,
      plainText: plainText,
      subject: subject,
      camouflageEnabled: camouflageEnabled,
    );
  }

  @override
  Future<String> decode({
    required String pairingId,
    required String encodedText,
  }) {
    return _cryptoFacade.decodeForPair(
      pairingId: pairingId,
      encodedText: encodedText,
    );
  }
}
