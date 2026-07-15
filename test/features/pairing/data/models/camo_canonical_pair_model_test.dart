import 'package:camo/features/pairing/data/models/camo_canonical_pair_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final created = DateTime.utc(2026, 7, 15, 10);
  final updated = DateTime.utc(2026, 7, 15, 11);

  Map<String, dynamic> validMap({String status = 'pending'}) =>
      <String, dynamic>{
        'schemaVersion': 1,
        'pairId': 'pair-1',
        'participantUserIds': <String>['uid-b', 'uid-a'],
        'status': status,
        'createdAt': Timestamp.fromDate(created),
        'updatedAt': Timestamp.fromDate(updated),
      };

  test('parses required fields and canonicalizes participant order', () {
    final model = CamoCanonicalPairModel.fromMap(validMap());
    expect(model.participantUserIds, <String>['uid-a', 'uid-b']);
    expect(model.status, CamoCanonicalPairStatus.pending);
  });

  test('serializes only canonical contract field names', () {
    final model = CamoCanonicalPairModel.fromMap(validMap());
    expect(model.toMap().keys, <String>[
      'schemaVersion',
      'pairId',
      'participantUserIds',
      'status',
      'createdAt',
      'updatedAt',
    ]);
    expect(model.toMap(), isNot(contains('active')));
    expect(model.toMap(), isNot(contains('senderId')));
    expect(model.toMap(), isNot(contains('receiverId')));
  });

  test('rejects missing or unknown status instead of defaulting', () {
    final missing = validMap()..remove('status');
    expect(
      () => CamoCanonicalPairModel.fromMap(missing),
      throwsFormatException,
    );
    expect(
      () => CamoCanonicalPairModel.fromMap(validMap(status: 'accepted')),
      throwsFormatException,
    );
  });

  test('rejects unsupported schema version', () {
    final map = validMap()..['schemaVersion'] = 2;
    expect(() => CamoCanonicalPairModel.fromMap(map), throwsFormatException);
  });

  test('rejects missing timestamps instead of using current time', () {
    final map = validMap()..remove('createdAt');
    expect(() => CamoCanonicalPairModel.fromMap(map), throwsFormatException);
  });

  test('requires exactly two distinct participant UIDs', () {
    final one = validMap()..['participantUserIds'] = <String>['uid-a'];
    final duplicate = validMap()
      ..['participantUserIds'] = <String>['uid-a', 'uid-a'];
    expect(() => CamoCanonicalPairModel.fromMap(one), throwsFormatException);
    expect(
      () => CamoCanonicalPairModel.fromMap(duplicate),
      throwsFormatException,
    );
  });

  test('rejects invalid pair document IDs', () {
    final map = validMap()..['pairId'] = 'folder/pair';
    expect(() => CamoCanonicalPairModel.fromMap(map), throwsFormatException);
  });

  test('requires requestedBy to be a participant', () {
    final map = validMap()..['requestedBy'] = 'uid-c';
    expect(() => CamoCanonicalPairModel.fromMap(map), throwsFormatException);
  });

  test('requires status-specific lifecycle timestamps', () {
    expect(
      () => CamoCanonicalPairModel.fromMap(validMap(status: 'active')),
      throwsFormatException,
    );
    final active = validMap(status: 'active')
      ..['acceptedAt'] = Timestamp.fromDate(updated);
    expect(
      CamoCanonicalPairModel.fromMap(active).status,
      CamoCanonicalPairStatus.active,
    );
  });
}
