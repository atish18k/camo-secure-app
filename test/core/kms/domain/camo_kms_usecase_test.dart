// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/kms/domain/entities/camo_key_purpose.dart';
import 'package:camo/core/kms/domain/entities/camo_key_reference.dart';
import 'package:camo/core/kms/domain/entities/camo_key_release_context.dart';
import 'package:camo/core/kms/domain/entities/camo_key_release_decision.dart';
import 'package:camo/core/kms/domain/entities/camo_key_scope.dart';
import 'package:camo/core/kms/domain/entities/camo_key_status.dart';
import 'package:camo/core/kms/domain/entities/camo_wrapped_key_material.dart';
import 'package:camo/core/kms/domain/repositories/camo_kms_repository.dart';
import 'package:camo/core/kms/domain/usecases/authorize_camo_key_release_usecase.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Fake Repository
// -----------------------------------------------------------------------------
final class _FakeKmsRepository implements CamoKmsRepository {
  @override
  Future<CamoResult<CamoKeyReleaseDecision>> authorizeKeyRelease(
    CamoKeyReleaseContext context,
  ) async {
    final DateTime now = DateTime.now();
    return CamoSuccess<CamoKeyReleaseDecision>(
      CamoKeyReleaseDecision(
        releaseId: 'release-001',
        authorizationId: context.authorizationId,
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: 'key_release_allowed',
        keyReference: CamoKeyReference(
          keyId: 'key-001',
          keyVersion: '1',
          provider: 'cloud-kms',
          purpose: context.keyPurpose,
          scope: context.keyScope,
          status: CamoKeyStatus.active,
          createdAt: now,
          expiresAt: now.add(const Duration(minutes: 1)),
        ),
        issuedAt: now,
        expiresAt: now.add(const Duration(seconds: 30)),
        singleUse: true,
      ),
    );
  }

  @override
  Future<CamoResult<CamoWrappedKeyMaterial>> releaseWrappedKey(
    CamoKeyReleaseDecision decision,
  ) async {
    final DateTime now = DateTime.now();
    return CamoSuccess<CamoWrappedKeyMaterial>(
      CamoWrappedKeyMaterial(
        releaseId: decision.releaseId,
        keyId: decision.keyReference.keyId,
        wrappedKey: 'wrapped-key-material',
        wrappingAlgorithm: 'x25519-hkdf-aes-gcm',
        deviceId: 'device-001',
        createdAt: now,
        expiresAt: decision.expiresAt,
      ),
    );
  }

  @override
  Future<CamoResult<void>> consumeKeyRelease(String releaseId) async {
    return const CamoSuccess<void>(null);
  }

  @override
  Future<CamoResult<CamoKeyReference>> rotateKey(String keyId) async {
    return CamoSuccess<CamoKeyReference>(
      CamoKeyReference(
        keyId: keyId,
        keyVersion: '2',
        provider: 'cloud-kms',
        purpose: CamoKeyPurpose.keyWrapping,
        scope: CamoKeyScope.tenant,
        status: CamoKeyStatus.active,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<CamoResult<void>> revokeKey(String keyId, String reasonCode) async {
    return const CamoSuccess<void>(null);
  }
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('authorize key release use case delegates to repository', () async {
    final AuthorizeCamoKeyReleaseUseCase useCase =
        AuthorizeCamoKeyReleaseUseCase(_FakeKmsRepository());
    final CamoKeyReleaseContext context = CamoKeyReleaseContext(
      authorizationId: 'authorization-001',
      operationId: 'operation-001',
      userId: 'user-001',
      deviceId: 'device-001',
      operationType: CamoOperationType.decode,
      keyPurpose: CamoKeyPurpose.messageDecryption,
      keyScope: CamoKeyScope.message,
      requestedAt: DateTime.now(),
      messageId: 'message-001',
    );
    final CamoResult<CamoKeyReleaseDecision> result = await useCase(context);
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.permitsKeyRelease, isTrue);
  });
}
