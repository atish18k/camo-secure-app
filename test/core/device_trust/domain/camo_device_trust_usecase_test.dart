// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/device_trust/domain/entities/camo_device_identity.dart';
import 'package:camo/core/device_trust/domain/entities/camo_device_status.dart';
import 'package:camo/core/device_trust/domain/entities/camo_device_trust_decision.dart';
import 'package:camo/core/device_trust/domain/repositories/camo_device_trust_repository.dart';
import 'package:camo/core/device_trust/domain/usecases/validate_camo_device_trust_usecase.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:camo/core/shared/types/camo_device_trust_level.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Fake Repository
// -----------------------------------------------------------------------------
final class _FakeDeviceTrustRepository implements CamoDeviceTrustRepository {
  @override
  Future<CamoResult<CamoDeviceIdentity>> registerDevice(
    CamoDeviceIdentity device,
  ) async {
    return CamoSuccess<CamoDeviceIdentity>(device);
  }

  @override
  Future<CamoResult<CamoDeviceIdentity>> approveDevice(String deviceId) async {
    return CamoSuccess<CamoDeviceIdentity>(
      CamoDeviceIdentity(
        deviceId: deviceId,
        userId: 'user-001',
        platform: 'android',
        publicKey: 'public-key',
        status: CamoDeviceStatus.approved,
        trustLevel: CamoDeviceTrustLevel.trusted,
        registeredAt: DateTime.now(),
        approvedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<CamoResult<void>> revokeDevice(
    String deviceId,
    String reasonCode,
  ) async {
    return const CamoSuccess<void>(null);
  }

  @override
  Future<CamoResult<CamoDeviceTrustDecision>> validateDeviceTrust(
    String deviceId,
    String userId,
  ) async {
    final DateTime now = DateTime.now();
    return CamoSuccess<CamoDeviceTrustDecision>(
      CamoDeviceTrustDecision(
        deviceId: deviceId,
        trustLevel: CamoDeviceTrustLevel.trusted,
        allowed: true,
        reasonCode: 'trusted_device',
        evaluatedAt: now,
        expiresAt: now.add(const Duration(seconds: 30)),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('validate use case delegates to repository', () async {
    final ValidateCamoDeviceTrustUseCase useCase =
        ValidateCamoDeviceTrustUseCase(_FakeDeviceTrustRepository());
    final CamoResult<CamoDeviceTrustDecision> result = await useCase(
      deviceId: 'device-001',
      userId: 'user-001',
    );
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.permitsOperation, isTrue);
  });
}
