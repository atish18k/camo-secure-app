import 'package:flutter_test/flutter_test.dart';

import 'package:camo/features/policy/data/models/camo_device_registry_model.dart';
import 'package:camo/features/policy/domain/entities/camo_device_registry_entity.dart';

void main() {
  Map<String, dynamic> validMap({required Object? status}) {
    return <String, dynamic>{
      'publicKey': 'public-key-001',
      'platform': 'windows',
      'status': status,
      'keyVersion': 1,
      'createdAt': '2026-07-15T00:00:00.000Z',
      'lastSeenAt': '2026-07-15T00:00:00.000Z',
    };
  }

  CamoDeviceRegistryModel parse(Map<String, dynamic> map) {
    return CamoDeviceRegistryModel.fromMap(
      deviceId: 'device-001',
      userId: 'user-001',
      map: map,
    );
  }

  test('parses the explicitly active legacy status', () {
    expect(parse(validMap(status: 'active')).status, CamoDeviceStatus.active);
  });

  test('parses the explicitly revoked legacy status', () {
    expect(parse(validMap(status: 'revoked')).status, CamoDeviceStatus.revoked);
  });

  test('parses the explicitly blocked legacy status', () {
    expect(parse(validMap(status: 'blocked')).status, CamoDeviceStatus.blocked);
  });

  test('fails closed when status is missing', () {
    final map = validMap(status: 'active')..remove('status');
    expect(() => parse(map), throwsFormatException);
  });

  test('fails closed when status is null', () {
    expect(() => parse(validMap(status: null)), throwsFormatException);
  });

  test('fails closed when status is unknown', () {
    expect(() => parse(validMap(status: 'unexpected')), throwsFormatException);
  });

  test('fails closed when status is not a string', () {
    expect(() => parse(validMap(status: 1)), throwsFormatException);
  });
}
