import 'dart:typed_data';

import 'package:camo/core/crypto/encryption/camo_key_pair.dart';
import 'package:camo/core/device_trust/domain/entities/camo_device_status.dart';
import 'package:camo/core/errors/result.dart';
import 'package:camo/features/auth/domain/repositories/auth_repository.dart';
import 'package:camo/features/pairing/security/device_key_manager.dart';
import 'package:camo/features/policy/data/repositories/camo_device_registration_service_impl.dart';
import 'package:camo/features/policy/domain/entities/camo_device_registry_entity.dart';
import 'package:camo/features/policy/domain/entities/camo_platform_info.dart';
import 'package:camo/features/policy/domain/repositories/camo_device_identity_service.dart';
import 'package:camo/features/policy/domain/repositories/camo_device_registry_repository.dart';
import 'package:camo/features/policy/domain/repositories/camo_platform_info_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CamoDeviceRegistrationServiceImpl', () {
    late _FakeAuthRepository authRepository;
    late _FakeDeviceIdentityService deviceIdentityService;
    late _FakePlatformInfoProvider platformInfoProvider;
    late _FakeDeviceKeyManager deviceKeyManager;
    late _FakeDeviceRegistryRepository deviceRegistryRepository;
    late CamoDeviceRegistrationServiceImpl service;

    setUp(() {
      authRepository = _FakeAuthRepository(currentUserIdValue: 'user-1');

      deviceIdentityService = _FakeDeviceIdentityService(deviceId: 'device-1');

      platformInfoProvider = const _FakePlatformInfoProvider();

      deviceKeyManager = _FakeDeviceKeyManager();

      deviceRegistryRepository = _FakeDeviceRegistryRepository();

      service = CamoDeviceRegistrationServiceImpl(
        authRepository,
        deviceIdentityService,
        platformInfoProvider,
        deviceKeyManager,
        deviceRegistryRepository,
      );
    });

    test('registers a new authenticated device', () async {
      final CamoDeviceRegistryEntity device = await service
          .registerCurrentDevice();

      expect(device.userId, 'user-1');
      expect(device.deviceId, 'device-1');
      expect(device.platform, 'web');
      expect(device.status, CamoDeviceStatus.approved);
      expect(device.keyVersion, 1);

      expect(deviceKeyManager.createInvocationCount, 1);
      expect(deviceKeyManager.saveInvocationCount, 1);

      expect(deviceRegistryRepository.registeredDevice, isNotNull);

      expect(
        deviceRegistryRepository.registeredDevice!.publicKey,
        device.publicKey,
      );
    });

    test(
      'reuses an existing matching approved device without a client write',
      () async {
        final CamoKeyPair keyPair = await deviceKeyManager.createKeyPair();

        await deviceKeyManager.saveKeyPair(keyPair);

        deviceRegistryRepository.existingDevice = CamoDeviceRegistryEntity(
          deviceId: 'device-1',
          userId: 'user-1',
          publicKey: 'AQIDBA==',
          platform: 'web',
          status: CamoDeviceStatus.approved,
          keyVersion: 1,
          createdAt: DateTime.utc(2026, 1, 1),
          lastSeenAt: DateTime.utc(2026, 1, 1),
        );

        final CamoDeviceRegistryEntity device = await service
            .registerCurrentDevice();

        expect(device.deviceId, 'device-1');
        expect(device.status, CamoDeviceStatus.approved);

        expect(deviceRegistryRepository.updateLastSeenInvocationCount, 0);

        expect(deviceRegistryRepository.registerInvocationCount, 0);
      },
    );

    test('denies registration when user is not authenticated', () async {
      authRepository.currentUserIdValue = null;

      expect(service.registerCurrentDevice, throwsA(isA<StateError>()));
    });

    test('denies a revoked existing device', () async {
      final CamoKeyPair keyPair = await deviceKeyManager.createKeyPair();

      await deviceKeyManager.saveKeyPair(keyPair);

      deviceRegistryRepository.existingDevice = CamoDeviceRegistryEntity(
        deviceId: 'device-1',
        userId: 'user-1',
        publicKey: 'AQIDBA==',
        platform: 'web',
        status: CamoDeviceStatus.revoked,
        keyVersion: 1,
        createdAt: DateTime.utc(2026, 1, 1),
        lastSeenAt: DateTime.utc(2026, 1, 1),
      );

      expect(service.registerCurrentDevice, throwsA(isA<StateError>()));

      expect(deviceRegistryRepository.updateLastSeenInvocationCount, 0);
    });

    test('denies a blacklisted existing device', () async {
      final CamoKeyPair keyPair = await deviceKeyManager.createKeyPair();

      await deviceKeyManager.saveKeyPair(keyPair);

      deviceRegistryRepository.existingDevice = CamoDeviceRegistryEntity(
        deviceId: 'device-1',
        userId: 'user-1',
        publicKey: 'AQIDBA==',
        platform: 'web',
        status: CamoDeviceStatus.blacklisted,
        keyVersion: 1,
        createdAt: DateTime.utc(2026, 1, 1),
        lastSeenAt: DateTime.utc(2026, 1, 1),
      );

      expect(service.registerCurrentDevice, throwsA(isA<StateError>()));
    });

    test('denies public key mismatch without overwriting registry', () async {
      final CamoKeyPair keyPair = await deviceKeyManager.createKeyPair();

      await deviceKeyManager.saveKeyPair(keyPair);

      deviceRegistryRepository.existingDevice = CamoDeviceRegistryEntity(
        deviceId: 'device-1',
        userId: 'user-1',
        publicKey: 'different-public-key',
        platform: 'web',
        status: CamoDeviceStatus.approved,
        keyVersion: 1,
        createdAt: DateTime.utc(2026, 1, 1),
        lastSeenAt: DateTime.utc(2026, 1, 1),
      );

      expect(service.registerCurrentDevice, throwsA(isA<StateError>()));

      expect(deviceRegistryRepository.registerInvocationCount, 0);

      expect(deviceRegistryRepository.updateLastSeenInvocationCount, 0);
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.currentUserIdValue});

  String? currentUserIdValue;

  @override
  String? get currentUserId => currentUserIdValue;

  @override
  bool get isSignedIn =>
      currentUserIdValue != null && currentUserIdValue!.isNotEmpty;

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> signOut() {
    throw UnimplementedError();
  }
}

class _FakeDeviceIdentityService implements CamoDeviceIdentityService {
  _FakeDeviceIdentityService({required this.deviceId});

  final String deviceId;

  @override
  Future<String> getDeviceId() async {
    return deviceId;
  }

  @override
  Future<void> deleteDeviceId() async {}
}

class _FakePlatformInfoProvider implements CamoPlatformInfoProvider {
  const _FakePlatformInfoProvider();

  @override
  CamoPlatformInfo getPlatformInfo() {
    return const CamoPlatformInfo(type: CamoPlatformType.web);
  }
}

class _FakeDeviceKeyManager implements DeviceKeyManager {
  CamoKeyPair? storedKeyPair;

  int createInvocationCount = 0;
  int saveInvocationCount = 0;

  @override
  Future<CamoKeyPair> createKeyPair() async {
    createInvocationCount++;

    return CamoKeyPair(
      privateKey: Uint8List.fromList(<int>[9, 8, 7, 6]),
      publicKey: Uint8List.fromList(<int>[1, 2, 3, 4]),
    );
  }

  @override
  Future<void> saveKeyPair(CamoKeyPair keyPair) async {
    saveInvocationCount++;
    storedKeyPair = keyPair;
  }

  @override
  Future<CamoKeyPair?> loadKeyPair() async {
    return storedKeyPair;
  }

  @override
  Future<bool> hasKeyPair() async {
    return storedKeyPair != null;
  }

  @override
  Future<void> deleteKeyPair() async {
    storedKeyPair = null;
  }
}

class _FakeDeviceRegistryRepository implements CamoDeviceRegistryRepository {
  CamoDeviceRegistryEntity? existingDevice;
  CamoDeviceRegistryEntity? registeredDevice;

  int registerInvocationCount = 0;
  int updateLastSeenInvocationCount = 0;

  @override
  Future<CamoDeviceRegistryEntity?> getDevice({
    required String userId,
    required String deviceId,
  }) async {
    return existingDevice;
  }

  @override
  Future<void> registerDevice(CamoDeviceRegistryEntity device) async {
    registerInvocationCount++;
    registeredDevice = device;
  }

  @override
  Future<void> submitRegistrationRequest({
    required String requestId,
    required String userId,
    required String deviceId,
    required String publicKey,
    required int keyVersion,
    required String platform,
    required DateTime requestedAt,
  }) async {}
  @override
  Future<void> updateLastSeen({
    required String userId,
    required String deviceId,
    required DateTime lastSeenAt,
  }) async {
    updateLastSeenInvocationCount++;
  }

  @override
  Future<CamoDeviceRegistryEntity?> getActiveDevice({
    required String userId,
  }) async {
    return null;
  }
}
