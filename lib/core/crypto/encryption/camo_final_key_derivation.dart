// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import '../server_share/camo_server_share.dart';

// ---------------------------------------------------------------------------
// CAMO Final Key Derivation
// ---------------------------------------------------------------------------

abstract interface class CamoFinalKeyDerivation {
  Future<Uint8List> deriveFinalKey({
    required Uint8List deviceSharedSecret,
    required CamoServerShare serverShare,
    required Uint8List salt,
    required List<int> info,
  });
}
