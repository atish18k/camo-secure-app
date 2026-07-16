import 'package:camo/core/device_trust/domain/entities/camo_device_status.dart';
import 'package:camo/features/policy/data/models/camo_device_registry_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> validMap({
    Object? status = 'approved',
    bool approved = true,
    bool revoked = false,
  }) => <String, dynamic>{
    'schemaVersion': 1,
    'deviceId': 'device-001',
    'userId': 'user-001',
    'publicKey': 'public-key-001',
    'platform': 'web',
    'status': status,
    'keyVersion': 1,
    'approved': approved,
    'revoked': revoked,
    'createdAt': Timestamp.fromDate(DateTime.utc(2026, 7, 15)),
    'updatedAt': Timestamp.fromDate(DateTime.utc(2026, 7, 16)),
  };

  CamoDeviceRegistryModel parse(Map<String, dynamic> map) =>
      CamoDeviceRegistryModel.fromMap(
        deviceId: 'device-001',
        userId: 'user-001',
        map: map,
      );

  test('parses exact canonical approved Firestore document', () {
    final device = parse(validMap());
    expect(device.status, CamoDeviceStatus.approved);
    expect(device.isApproved, isTrue);
    expect(device.createdAt, DateTime.utc(2026, 7, 15));
    expect(device.lastSeenAt, DateTime.utc(2026, 7, 16));
  });

  test('parses canonical revoked device as blocked', () {
    final device = parse(
      validMap(status: 'revoked', approved: false, revoked: true),
    );
    expect(device.status, CamoDeviceStatus.revoked);
    expect(device.isBlocked, isTrue);
  });

  test('parses canonical blacklisted device as blocked', () {
    final device = parse(validMap(status: 'blacklisted', approved: false));
    expect(device.status, CamoDeviceStatus.blacklisted);
    expect(device.isBlocked, isTrue);
  });

  test('pending device is parsed but never approved', () {
    final device = parse(validMap(status: 'pending', approved: false));
    expect(device.status, CamoDeviceStatus.pending);
    expect(device.isApproved, isFalse);
  });

  test('rejects legacy active and blocked statuses', () {
    expect(() => parse(validMap(status: 'active')), throwsFormatException);
    expect(() => parse(validMap(status: 'blocked')), throwsFormatException);
  });

  test('fails closed for missing null unknown and non-string status', () {
    final missing = validMap()..remove('status');
    expect(() => parse(missing), throwsFormatException);
    expect(() => parse(validMap(status: null)), throwsFormatException);
    expect(() => parse(validMap(status: 'unexpected')), throwsFormatException);
    expect(() => parse(validMap(status: 1)), throwsFormatException);
  });

  test('fails closed for invalid schema identity and key version', () {
    expect(
      () => parse(validMap()..['schemaVersion'] = 2),
      throwsFormatException,
    );
    expect(
      () => parse(validMap()..['deviceId'] = 'other'),
      throwsFormatException,
    );
    expect(
      () => parse(validMap()..['userId'] = 'other'),
      throwsFormatException,
    );
    expect(() => parse(validMap()..['keyVersion'] = 0), throwsFormatException);
  });

  test('fails closed for string or missing canonical timestamps', () {
    expect(
      () => parse(validMap()..['createdAt'] = '2026-07-15T00:00:00Z'),
      throwsFormatException,
    );
    expect(() => parse(validMap()..remove('updatedAt')), throwsFormatException);
  });

  test('fails closed when boolean flags contradict canonical status', () {
    expect(() => parse(validMap(approved: false)), throwsFormatException);
    expect(
      () => parse(validMap(status: 'revoked', approved: false, revoked: false)),
      throwsFormatException,
    );
  });
}
