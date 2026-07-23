// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../data/models/camo_verified_signed_permit_projection_v2.dart';

// ---------------------------------------------------------------------------
// Verified V2 Permit Store
// ---------------------------------------------------------------------------

abstract interface class CamoVerifiedV2PermitStore {
  Future<void> save({
    required String requestId,
    required CamoVerifiedSignedPermitProjectionV2 permit,
  });

  Future<CamoVerifiedSignedPermitProjectionV2?> consume({
    required String requestId,
    required String operationId,
  });

  Future<void> remove({required String requestId});

  Future<void> clear();
}
