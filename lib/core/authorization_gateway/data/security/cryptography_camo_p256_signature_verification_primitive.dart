import 'package:cryptography/cryptography.dart';

import 'camo_p256_signature_verification_primitive.dart';

final class CryptographyCamoP256SignatureVerificationPrimitive
    implements CamoP256SignatureVerificationPrimitive {
  CryptographyCamoP256SignatureVerificationPrimitive({Ecdsa? algorithm})
    : _algorithm = algorithm ?? Ecdsa.p256(Sha256());

  final Ecdsa _algorithm;

  @override
  Future<bool> verify({
    required List<int> message,
    required List<int> rawSignature,
    required List<int> publicKeyX,
    required List<int> publicKeyY,
  }) async {
    if (rawSignature.length != 64 ||
        publicKeyX.length != 32 ||
        publicKeyY.length != 32) {
      return false;
    }

    final EcPublicKey publicKey = EcPublicKey(
      x: List<int>.unmodifiable(publicKeyX),
      y: List<int>.unmodifiable(publicKeyY),
      type: KeyPairType.p256,
    );

    return _algorithm.verify(
      List<int>.unmodifiable(message),
      signature: Signature(
        List<int>.unmodifiable(rawSignature),
        publicKey: publicKey,
      ),
    );
  }
}
