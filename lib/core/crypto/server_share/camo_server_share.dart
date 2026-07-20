// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:typed_data';

// ---------------------------------------------------------------------------
// CAMO Server Share
// ---------------------------------------------------------------------------

final class CamoServerShare {
  CamoServerShare({
    required this.shareId,
    required this.operationId,
    required this.version,
    required this.expiresAt,
    required Uint8List bytes,
  }) : bytes = Uint8List.fromList(bytes);

  final String shareId;
  final String operationId;
  final int version;
  final DateTime expiresAt;
  final Uint8List bytes;
}
