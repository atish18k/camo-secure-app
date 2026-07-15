import 'dart:convert';

import 'package:camo/features/policy/data/models/camo_device_registration_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final publicKey = base64Encode(List<int>.generate(32, (index) => index));

  CamoDeviceRegistrationRequestModel build({
    String requestId = 'request-001',
    String userId = 'user-001',
    String deviceId = 'device-001',
    String? encodedPublicKey,
    int keyVersion = 1,
    String platform = 'windows',
  }) {
    return CamoDeviceRegistrationRequestModel(
      requestId: requestId,
      userId: userId,
      deviceId: deviceId,
      publicKey: encodedPublicKey ?? publicKey,
      keyVersion: keyVersion,
      platform: platform,
      requestedAt: DateTime.parse('2026-07-15T12:30:00+05:30'),
    );
  }

  test('serializes the exact locked client-fact contract', () {
    expect(build().toMap(), <String, dynamic>{
      'schemaVersion': 1,
      'requestId': 'request-001',
      'userId': 'user-001',
      'deviceId': 'device-001',
      'publicKey': publicKey,
      'keyVersion': 1,
      'platform': 'windows',
      'status': 'pending',
      'requestedAt': '2026-07-15T07:00:00.000Z',
    });
  });

  test('locks status to pending with no caller override', () {
    expect(build().status, 'pending');
  });

  test('never serializes server resolution fields', () {
    final map = build().toMap();
    expect(map.containsKey('resolvedAt'), isFalse);
    expect(map.containsKey('resolvedBy'), isFalse);
    expect(map.containsKey('rejectionReason'), isFalse);
    expect(map.containsKey('approved'), isFalse);
  });

  test('normalizes identifiers and platform', () {
    final model = build(
      requestId: ' request-001 ',
      userId: ' user-001 ',
      deviceId: ' device-001 ',
      platform: ' windows ',
    );
    expect(model.requestId, 'request-001');
    expect(model.userId, 'user-001');
    expect(model.deviceId, 'device-001');
    expect(model.platform, 'windows');
  });

  test('rejects empty or path-bearing identifiers', () {
    expect(() => build(requestId: ''), throwsFormatException);
    expect(() => build(requestId: 'a/b'), throwsFormatException);
    expect(() => build(userId: 'a/b'), throwsFormatException);
    expect(() => build(deviceId: 'a/b'), throwsFormatException);
  });

  test('rejects invalid key version and platform', () {
    expect(() => build(keyVersion: 0), throwsFormatException);
    expect(() => build(platform: ' '), throwsFormatException);
  });

  test('rejects malformed or wrong-length public keys', () {
    expect(() => build(encodedPublicKey: 'not-base64'), throwsFormatException);
    expect(
      () => build(encodedPublicKey: base64Encode(<int>[1, 2, 3])),
      throwsFormatException,
    );
  });
}
