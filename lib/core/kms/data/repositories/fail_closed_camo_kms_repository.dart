import '../../../shared/failures/camo_failure.dart';
import '../../../shared/result/camo_result.dart';
import '../../domain/entities/camo_key_reference.dart';
import '../../domain/entities/camo_key_release_context.dart';
import '../../domain/entities/camo_key_release_decision.dart';
import '../../domain/entities/camo_wrapped_key_material.dart';
import '../../domain/repositories/camo_kms_repository.dart';

final class FailClosedCamoKmsRepository implements CamoKmsRepository {
  const FailClosedCamoKmsRepository();

  @override
  Future<CamoResult<CamoKeyReleaseDecision>> authorizeKeyRelease(
    CamoKeyReleaseContext context,
  ) async {
    return const CamoError<CamoKeyReleaseDecision>(
      CamoSecurityFailure(
        code: 'kms_key_release_authorization_unavailable',
        message: 'Production KMS key-release authorization is unavailable.',
      ),
    );
  }

  @override
  Future<CamoResult<CamoWrappedKeyMaterial>> releaseWrappedKey(
    CamoKeyReleaseDecision decision,
  ) async {
    return const CamoError<CamoWrappedKeyMaterial>(
      CamoSecurityFailure(
        code: 'kms_wrapped_key_release_unavailable',
        message: 'Production wrapped-key release is unavailable.',
      ),
    );
  }

  @override
  Future<CamoResult<void>> consumeKeyRelease(String releaseId) async {
    if (releaseId.trim().isEmpty) {
      return const CamoError<void>(
        CamoValidationFailure(
          code: 'kms_release_id_invalid',
          message: 'KMS release identifier is required.',
        ),
      );
    }

    return const CamoError<void>(
      CamoSecurityFailure(
        code: 'kms_key_release_consumption_unavailable',
        message: 'Production KMS key-release consumption is unavailable.',
      ),
    );
  }

  @override
  Future<CamoResult<CamoKeyReference>> rotateKey(String keyId) async {
    if (keyId.trim().isEmpty) {
      return const CamoError<CamoKeyReference>(
        CamoValidationFailure(
          code: 'kms_key_id_invalid',
          message: 'KMS key identifier is required.',
        ),
      );
    }

    return const CamoError<CamoKeyReference>(
      CamoSecurityFailure(
        code: 'kms_key_rotation_unavailable',
        message: 'Production KMS key rotation is unavailable.',
      ),
    );
  }

  @override
  Future<CamoResult<void>> revokeKey(String keyId, String reasonCode) async {
    if (keyId.trim().isEmpty) {
      return const CamoError<void>(
        CamoValidationFailure(
          code: 'kms_key_id_invalid',
          message: 'KMS key identifier is required.',
        ),
      );
    }

    if (reasonCode.trim().isEmpty) {
      return const CamoError<void>(
        CamoValidationFailure(
          code: 'kms_revocation_reason_invalid',
          message: 'KMS key-revocation reason is required.',
        ),
      );
    }

    return const CamoError<void>(
      CamoSecurityFailure(
        code: 'kms_key_revocation_unavailable',
        message: 'Production KMS key revocation is unavailable.',
      ),
    );
  }
}
