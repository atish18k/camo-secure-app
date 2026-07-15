import 'package:camo/core/authorization_gateway/data/security/camo_pinned_authorization_public_key_v1.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const CamoPinnedAuthorizationPublicKeyV1 pinnedKey =
      CamoPinnedAuthorizationPublicKeyV1();

  test('pins exact KMS signing key version identity', () {
    expect(
      CamoPinnedAuthorizationPublicKeyV1.signingKeyId,
      'camo-b3cab:asia-south1:camo-prod-authz-kr:'
      'camo-operation-signing:1',
    );

    expect(CamoPinnedAuthorizationPublicKeyV1.algorithm, 'EC_SIGN_P256_SHA256');
  });

  test('pins valid 32-byte P-256 coordinates', () {
    expect(pinnedKey.x, hasLength(32));
    expect(pinnedKey.y, hasLength(32));

    final EcPublicKey publicKey = pinnedKey.toPublicKey();

    expect(publicKey.type, KeyPairType.p256);
    expect(publicKey.x, pinnedKey.x);
    expect(publicKey.y, pinnedKey.y);
  });

  test('pinned SPKI fingerprint matches audited KMS key', () async {
    expect(pinnedKey.toSpkiDer(), hasLength(91));
    expect(await pinnedKey.hasValidSpkiSha256(), isTrue);
  });
}
