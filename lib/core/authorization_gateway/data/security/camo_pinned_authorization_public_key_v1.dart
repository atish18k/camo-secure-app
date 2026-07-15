import 'dart:convert';

import 'package:cryptography/cryptography.dart';

final class CamoPinnedAuthorizationPublicKeyV1 {
  const CamoPinnedAuthorizationPublicKeyV1();

  static const String signingKeyId =
      'camo-b3cab:asia-south1:camo-prod-authz-kr:'
      'camo-operation-signing:1';

  static const String keyVersionName =
      'projects/camo-b3cab/locations/asia-south1/'
      'keyRings/camo-prod-authz-kr/cryptoKeys/'
      'camo-operation-signing/cryptoKeyVersions/1';

  static const String algorithm = 'EC_SIGN_P256_SHA256';

  static const String spkiSha256 =
      '201572d442be3a0b3b237c04a0dfd260'
      '84d7276c87651234ec944ce945fff5b7';

  static const String _xBase64 = 'SYffhXwt5s7qA03X8ggXSjkW1yhp0T3Q+h0QiWzVVyc=';

  static const String _yBase64 = 'uBJ0hHTLxZP21pTiQZ1ffEsHl2mJJEBIo2otZ9VUOEE=';

  static const List<int> _spkiPrefix = <int>[
    0x30,
    0x59,
    0x30,
    0x13,
    0x06,
    0x07,
    0x2a,
    0x86,
    0x48,
    0xce,
    0x3d,
    0x02,
    0x01,
    0x06,
    0x08,
    0x2a,
    0x86,
    0x48,
    0xce,
    0x3d,
    0x03,
    0x01,
    0x07,
    0x03,
    0x42,
    0x00,
    0x04,
  ];

  List<int> get x {
    return _decodeCoordinate(_xBase64, 'x');
  }

  List<int> get y {
    return _decodeCoordinate(_yBase64, 'y');
  }

  EcPublicKey toPublicKey() {
    return EcPublicKey(x: x, y: y, type: KeyPairType.p256);
  }

  List<int> toSpkiDer() {
    final List<int> value = <int>[..._spkiPrefix, ...x, ...y];

    if (value.length != 91) {
      throw StateError(
        'Pinned authorization public key SPKI length is invalid.',
      );
    }

    return List<int>.unmodifiable(value);
  }

  Future<bool> hasValidSpkiSha256() async {
    final Hash digest = await Sha256().hash(toSpkiDer());

    final String actual = digest.bytes
        .map((int value) => value.toRadixString(16).padLeft(2, '0'))
        .join();

    return _constantTimeEquals(actual, spkiSha256);
  }

  List<int> _decodeCoordinate(String encoded, String coordinateName) {
    final List<int> value;

    try {
      value = base64Decode(encoded);
    } on Object {
      throw FormatException(
        'Pinned P-256 $coordinateName coordinate is not valid Base64.',
      );
    }

    if (value.length != 32) {
      throw FormatException(
        'Pinned P-256 $coordinateName coordinate length is invalid.',
      );
    }

    return List<int>.unmodifiable(value);
  }

  bool _constantTimeEquals(String left, String right) {
    if (left.length != right.length) {
      return false;
    }

    int difference = 0;

    for (int index = 0; index < left.length; index++) {
      difference |= left.codeUnitAt(index) ^ right.codeUnitAt(index);
    }

    return difference == 0;
  }
}
