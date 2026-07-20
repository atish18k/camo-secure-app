// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:camo/core/crypto/encryption/camo_hkdf_final_key_derivation.dart';
import 'package:camo/core/crypto/server_share/camo_server_share.dart';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const CamoHkdfFinalKeyDerivation derivation = CamoHkdfFinalKeyDerivation();

  CamoServerShare serverShare({
    int fill = 9,
    String operationId = 'operation-001',
  }) {
    return CamoServerShare(
      shareId: 'share-001',
      operationId: operationId,
      version: 1,
      expiresAt: DateTime.utc(2030),
      bytes: Uint8List.fromList(List<int>.filled(32, fill)),
    );
  }

  Future<Uint8List> derive({CamoServerShare? share, List<int>? info}) {
    return derivation.deriveFinalKey(
      deviceSharedSecret: Uint8List.fromList(
        List<int>.generate(32, (int index) => index),
      ),
      serverShare: share ?? serverShare(),
      salt: Uint8List.fromList(List<int>.filled(32, 4)),
      info: info ?? utf8.encode('CAMO|final-key|v1|operation-001'),
    );
  }

  test('derives a deterministic 32-byte final key', () async {
    final Uint8List first = await derive();
    final Uint8List second = await derive();

    expect(first, hasLength(32));
    expect(second, orderedEquals(first));
  });

  test('different server share produces a different final key', () async {
    final Uint8List first = await derive();
    final Uint8List second = await derive(share: serverShare(fill: 10));

    expect(second, isNot(orderedEquals(first)));
  });

  test('different operation context produces a different final key', () async {
    final Uint8List first = await derive();
    final Uint8List second = await derive(
      info: utf8.encode('CAMO|final-key|v1|operation-002'),
    );

    expect(second, isNot(orderedEquals(first)));
  });

  test('rejects an invalid server share length', () async {
    final CamoServerShare invalid = CamoServerShare(
      shareId: 'share-001',
      operationId: 'operation-001',
      version: 1,
      expiresAt: DateTime.utc(2030),
      bytes: Uint8List.fromList(List<int>.filled(31, 9)),
    );

    await expectLater(derive(share: invalid), throwsStateError);
  });
}
