// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'camo_server_share.dart';

// ---------------------------------------------------------------------------
// CAMO Server Share Validator
// ---------------------------------------------------------------------------

final class CamoServerShareValidator {
  const CamoServerShareValidator();

  static const int requiredByteLength = 32;

  void validate({
    required CamoServerShare serverShare,
    required String expectedOperationId,
    required DateTime now,
  }) {
    if (serverShare.shareId.trim().isEmpty) {
      throw StateError('Server share identifier is required.');
    }

    if (serverShare.operationId.trim().isEmpty) {
      throw StateError('Server share operation identifier is required.');
    }

    if (expectedOperationId.trim().isEmpty) {
      throw StateError('Expected operation identifier is required.');
    }

    if (serverShare.operationId != expectedOperationId) {
      throw StateError('Server share is not bound to this operation.');
    }

    if (serverShare.version <= 0) {
      throw StateError('Server share version must be positive.');
    }

    if (serverShare.bytes.length != requiredByteLength) {
      throw StateError('Server share must contain exactly 32 bytes.');
    }

    if (!serverShare.expiresAt.isAfter(now)) {
      throw StateError('Server share has expired.');
    }
  }
}
