// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:camo/core/crypto/server_share/camo_server_share.dart';
import 'package:camo/core/crypto/server_share/camo_server_share_validator.dart';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  const CamoServerShareValidator validator = CamoServerShareValidator();

  CamoServerShare validShare() {
    return CamoServerShare(
      shareId: 'share-001',
      operationId: 'operation-001',
      version: 1,
      expiresAt: DateTime.utc(2030),
      bytes: Uint8List.fromList(List<int>.filled(32, 7)),
    );
  }

  test('accepts a valid operation-bound server share', () {
    expect(
      () => validator.validate(
        serverShare: validShare(),
        expectedOperationId: 'operation-001',
        now: DateTime.utc(2029),
      ),
      returnsNormally,
    );
  });

  test('rejects a server share bound to another operation', () {
    expect(
      () => validator.validate(
        serverShare: validShare(),
        expectedOperationId: 'operation-002',
        now: DateTime.utc(2029),
      ),
      throwsStateError,
    );
  });

  test('rejects an expired server share', () {
    expect(
      () => validator.validate(
        serverShare: validShare(),
        expectedOperationId: 'operation-001',
        now: DateTime.utc(2030),
      ),
      throwsStateError,
    );
  });

  test('rejects a server share that is not exactly 32 bytes', () {
    final CamoServerShare invalid = CamoServerShare(
      shareId: 'share-001',
      operationId: 'operation-001',
      version: 1,
      expiresAt: DateTime.utc(2030),
      bytes: Uint8List.fromList(List<int>.filled(31, 7)),
    );

    expect(
      () => validator.validate(
        serverShare: invalid,
        expectedOperationId: 'operation-001',
        now: DateTime.utc(2029),
      ),
      throwsStateError,
    );
  });
}
