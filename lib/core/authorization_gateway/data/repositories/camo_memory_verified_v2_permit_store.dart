// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/repositories/camo_verified_v2_permit_store.dart';
import '../models/camo_verified_signed_permit_projection_v2.dart';

// ---------------------------------------------------------------------------
// Memory-backed Verified V2 Permit Store
// ---------------------------------------------------------------------------

final class CamoMemoryVerifiedV2PermitStore
    implements CamoVerifiedV2PermitStore {
  final Map<String, CamoVerifiedSignedPermitProjectionV2> _permits =
      <String, CamoVerifiedSignedPermitProjectionV2>{};

  @override
  Future<void> save({
    required String requestId,
    required CamoVerifiedSignedPermitProjectionV2 permit,
  }) async {
    final String normalizedRequestId = requestId.trim();

    if (normalizedRequestId.isEmpty ||
        permit.operationId.trim().isEmpty ||
        permit.authorizationId.trim().isEmpty ||
        permit.challengeId.trim().isEmpty ||
        permit.messageId.trim().isEmpty ||
        permit.serverShare.operationId.trim() != permit.operationId.trim()) {
      throw StateError('Verified V2 permit is invalid.');
    }

    if (_permits.containsKey(normalizedRequestId)) {
      throw StateError('Verified V2 permit request is already stored.');
    }

    _permits[normalizedRequestId] = permit;
  }

  @override
  Future<CamoVerifiedSignedPermitProjectionV2?> consume({
    required String requestId,
    required String operationId,
  }) async {
    final String normalizedRequestId = requestId.trim();
    final String normalizedOperationId = operationId.trim();

    if (normalizedRequestId.isEmpty || normalizedOperationId.isEmpty) {
      return null;
    }

    final CamoVerifiedSignedPermitProjectionV2? permit =
        _permits[normalizedRequestId];

    if (permit == null ||
        permit.operationId.trim() != normalizedOperationId ||
        permit.serverShare.operationId.trim() != normalizedOperationId) {
      return null;
    }

    _permits.remove(normalizedRequestId);
    return permit;
  }

  @override
  Future<void> remove({required String requestId}) async {
    final String normalizedRequestId = requestId.trim();

    if (normalizedRequestId.isEmpty) {
      return;
    }

    _permits.remove(normalizedRequestId);
  }

  @override
  Future<void> clear() async {
    _permits.clear();
  }
}
