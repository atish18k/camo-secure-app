import 'package:camo/features/policy/data/repositories/camo_device_identity_service_impl.dart';
import 'package:camo/features/policy/domain/repositories/camo_device_id_generator.dart';
import 'package:camo/services/secure_storage/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CamoDeviceIdentityServiceImpl', () {
    late _FakeSecureStorageService secureStorage;
    late _FakeDeviceIdGenerator deviceIdGenerator;
    late CamoDeviceIdentityServiceImpl service;

    setUp(() {
      secureStorage = _FakeSecureStorageService();
      deviceIdGenerator = _FakeDeviceIdGenerator(
        generatedValue: '123e4567-e89b-42d3-a456-426614174000',
      );

      service = CamoDeviceIdentityServiceImpl(
        secureStorage,
        deviceIdGenerator,
      );
    });

    test('generates and securely stores device id when missing', () async {
      final String deviceId = await service.getDeviceId();

      expect(
        deviceId,
        '123e4567-e89b-42d3-a456-426614174000',
      );

      expect(
        secureStorage.values['camo_device_identity_v1'],
        deviceId,
      );

      expect(deviceIdGenerator.invocationCount, 1);
    });

    test('returns existing stored device id without generating a new one',
        () async {
      secureStorage.values['camo_device_identity_v1'] =
          'existing-device-id';

      final String deviceId = await service.getDeviceId();

      expect(deviceId, 'existing-device-id');
      expect(deviceIdGenerator.invocationCount, 0);
    });

    test('returns the same device id across repeated calls', () async {
      final String firstDeviceId = await service.getDeviceId();
      final String secondDeviceId = await service.getDeviceId();

      expect(secondDeviceId, firstDeviceId);
      expect(deviceIdGenerator.invocationCount, 1);
    });

    test('trims an existing stored device id', () async {
      secureStorage.values['camo_device_identity_v1'] =
          '  existing-device-id  ';

      final String deviceId = await service.getDeviceId();

      expect(deviceId, 'existing-device-id');
      expect(deviceIdGenerator.invocationCount, 0);
    });

    test('generates a new id when stored value is empty', () async {
      secureStorage.values['camo_device_identity_v1'] = '   ';

      final String deviceId = await service.getDeviceId();

      expect(
        deviceId,
        '123e4567-e89b-42d3-a456-426614174000',
      );

      expect(deviceIdGenerator.invocationCount, 1);
    });

    test('deletes the stored device id', () async {
      await service.getDeviceId();

      await service.deleteDeviceId();

      expect(
        secureStorage.values.containsKey(
          'camo_device_identity_v1',
        ),
        isFalse,
      );
    });

    test('deleteAll clears all stored values', () async {
      secureStorage.values['one'] = '1';
      secureStorage.values['two'] = '2';

      await secureStorage.deleteAll();

      expect(secureStorage.values, isEmpty);
    });
  });
}

class _FakeDeviceIdGenerator implements CamoDeviceIdGenerator {
  _FakeDeviceIdGenerator({
    required this.generatedValue,
  });

  final String generatedValue;

  int invocationCount = 0;

  @override
  String generate() {
    invocationCount++;
    return generatedValue;
  }
}

class _FakeSecureStorageService implements SecureStorageService {
  final Map<String, String> values = <String, String>{};

  @override
  Future<void> delete({
    required String key,
  }) async {
    values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    values.clear();
  }

  @override
  Future<String?> read({
    required String key,
  }) async {
    return values[key];
  }

  @override
  Future<void> write({
    required String key,
    required String value,
  }) async {
    values[key] = value;
  }
}
