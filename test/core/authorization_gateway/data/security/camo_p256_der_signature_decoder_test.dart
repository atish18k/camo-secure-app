import 'package:camo/core/authorization_gateway/data/security/camo_p256_der_signature_decoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const CamoP256DerSignatureDecoder decoder = CamoP256DerSignatureDecoder();

  List<int> createStandardSignature() {
    final List<int> r = <int>[0x01, ...List<int>.filled(31, 0x11)];
    final List<int> s = <int>[0x02, ...List<int>.filled(31, 0x22)];

    return <int>[0x30, 0x44, 0x02, 0x20, ...r, 0x02, 0x20, ...s];
  }

  test('decodes standard P-256 DER signature to 64-byte raw form', () {
    final List<int> raw = decoder.decode(createStandardSignature());

    expect(raw, hasLength(64));
    expect(raw.first, 0x01);
    expect(raw[32], 0x02);
  });

  test('removes required positive-integer leading zero', () {
    final List<int> r = <int>[0x80, ...List<int>.filled(31, 0x11)];
    final List<int> s = <int>[0x7f, ...List<int>.filled(31, 0x22)];

    final List<int> der = <int>[
      0x30,
      0x45,
      0x02,
      0x21,
      0x00,
      ...r,
      0x02,
      0x20,
      ...s,
    ];

    final List<int> raw = decoder.decode(der);

    expect(raw, hasLength(64));
    expect(raw.first, 0x80);
    expect(raw[32], 0x7f);
  });

  test('rejects invalid sequence tag', () {
    final List<int> der = createStandardSignature()..[0] = 0x31;

    expect(() => decoder.decode(der), throwsFormatException);
  });

  test('rejects negative DER integer', () {
    final List<int> der = createStandardSignature()..[4] = 0x80;

    expect(() => decoder.decode(der), throwsFormatException);
  });

  test('rejects non-minimal DER integer padding', () {
    final List<int> s = <int>[0x02, ...List<int>.filled(31, 0x22)];

    final List<int> der = <int>[
      0x30,
      0x45,
      0x02,
      0x21,
      0x00,
      0x01,
      ...List<int>.filled(31, 0x11),
      0x02,
      0x20,
      ...s,
    ];

    expect(() => decoder.decode(der), throwsFormatException);
  });

  test('rejects trailing signature bytes', () {
    final List<int> der = <int>[...createStandardSignature(), 0x00];

    expect(() => decoder.decode(der), throwsFormatException);
  });
}
