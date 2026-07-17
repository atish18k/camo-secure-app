import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pairing queries constrain the canonical participant field', () {
    final source = File(
      'lib/features/pairing/data/datasources/pairing_remote_datasource.dart',
    ).readAsStringSync();
    expect(RegExp("'participantUserIds'").allMatches(source).length, 4);
    expect(source, isNot(contains('Filter.or(')));
  });

  test('pairing composite indexes are version controlled', () {
    final indexes = File('firestore.indexes.json').readAsStringSync();
    final firebase = File('firebase.json').readAsStringSync();
    expect(indexes, contains('participantUserIds'));
    expect(indexes, contains('receiverUid'));
    expect(indexes, contains('requesterUid'));
    expect(firebase, contains('firestore.indexes.json'));
  });
}
