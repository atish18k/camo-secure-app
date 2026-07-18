import 'package:camo/features/profile/data/models/user_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> validMap() => <String, dynamic>{
    'uid': 'user-1',
    'camoId': 'CAMO-123',
    'email': 'user@example.com',
    'displayName': 'CAMO User',
    'photoUrl': null,
    'createdAt': '2026-07-19T00:00:00.000Z',
  };

  test('parses the exact required profile facts', () {
    final model = UserProfileModel.fromMap(validMap());
    expect(model.uid, 'user-1');
    expect(model.camoId, 'CAMO-123');
    expect(model.createdAt, DateTime.utc(2026, 7, 19));
  });

  for (final key in <String>['uid', 'camoId', 'email', 'createdAt']) {
    test('fails closed when $key is missing', () {
      final map = validMap()..remove(key);
      expect(() => UserProfileModel.fromMap(map), throwsFormatException);
    });
  }

  test('fails closed for malformed createdAt instead of using local time', () {
    final map = validMap()..['createdAt'] = 'not-a-timestamp';
    expect(() => UserProfileModel.fromMap(map), throwsFormatException);
  });

  test('fails closed for a non-string optional field', () {
    final map = validMap()..['displayName'] = 7;
    expect(() => UserProfileModel.fromMap(map), throwsFormatException);
  });

  test('refuses to serialize an empty canonical identity', () {
    final model = UserProfileModel(
      uid: ' ',
      camoId: 'CAMO-123',
      email: 'user@example.com',
      createdAt: DateTime.utc(2026, 7, 19),
    );
    expect(model.toMap, throwsFormatException);
  });
}
