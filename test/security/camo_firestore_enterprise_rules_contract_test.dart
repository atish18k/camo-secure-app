import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('commercial projections remain owner-get-only and server writable', () {
    final rules = File('firestore.rules').readAsStringSync();

    for (final collection in <String>[
      'commercialAccess',
      'commercialAccessV2',
    ]) {
      expect(rules, contains('match /$collection/{docId}'));
    }

    expect(
      rules,
      contains("allow get: if isOwner(userId) && docId == 'current'"),
    );
    expect(rules, contains('allow list, create, update, delete: if false'));
  });

  test(
    'enterprise authority collections remain direct-client inaccessible',
    () {
      final rules = File('firestore.rules').readAsStringSync();

      for (final collection in <String>[
        'enterprisePolicies',
        'enterpriseRiskDecisions',
        'messagePolicies',
        'enterpriseAuthorizationConsumptions',
      ]) {
        expect(rules, contains('match /$collection/{document=**}'));
      }

      expect(rules, contains('allow read, write: if false'));
    },
  );

  test('rules emulator package is isolated from functions dependencies', () {
    final rulesPackage = File(
      'firestore_rules_tests/package.json',
    ).readAsStringSync();
    final functionsPackage = File('functions/package.json').readAsStringSync();
    final emulatorTest = File(
      'firestore_rules_tests/firestore_rules_negative.test.mjs',
    ).readAsStringSync();

    expect(rulesPackage, contains('@firebase/rules-unit-testing'));
    expect(rulesPackage, contains('"firebase"'));
    expect(rulesPackage, contains('"firebase-tools"'));
    expect(rulesPackage, contains('--config ../firebase.json'));
    expect(functionsPackage, isNot(contains('@firebase/rules-unit-testing')));
    expect(emulatorTest, contains('assertFails'));
    expect(emulatorTest, contains('assertSucceeds'));
    expect(emulatorTest, contains('unexpectedAuthority'));
  });
}
