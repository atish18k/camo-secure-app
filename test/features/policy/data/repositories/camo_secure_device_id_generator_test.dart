import 'package:camo/features/policy/data/repositories/camo_secure_device_id_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CamoSecureDeviceIdGenerator', () {
    test('generates a valid UUID v4 compatible device identifier', () {
      final CamoSecureDeviceIdGenerator generator =
          CamoSecureDeviceIdGenerator();

      final String deviceId = generator.generate();

      final RegExp uuidV4Pattern = RegExp(
        r'^[0-9a-f]{8}-'
        r'[0-9a-f]{4}-'
        r'4[0-9a-f]{3}-'
        r'[89ab][0-9a-f]{3}-'
        r'[0-9a-f]{12}$',
      );

      expect(deviceId, matches(uuidV4Pattern));
    });

    test('generates a different identifier for every invocation', () {
      final CamoSecureDeviceIdGenerator generator =
          CamoSecureDeviceIdGenerator();

      final Set<String> generatedIds = <String>{};

      for (int index = 0; index < 1000; index++) {
        generatedIds.add(
          generator.generate(),
        );
      }

      expect(generatedIds.length, 1000);
    });

    test('does not expose hardware or personal information', () {
      final CamoSecureDeviceIdGenerator generator =
          CamoSecureDeviceIdGenerator();

      final String deviceId = generator.generate();

      expect(deviceId.length, 36);
      expect(deviceId.contains('@'), isFalse);
      expect(deviceId.contains(' '), isFalse);
      expect(deviceId, isNot(contains('android')));
      expect(deviceId, isNot(contains('windows')));
      expect(deviceId, isNot(contains('device')));
    });
  });
}
