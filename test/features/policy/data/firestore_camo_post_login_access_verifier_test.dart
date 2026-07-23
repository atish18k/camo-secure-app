import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('commercialAccessV2 verifier locks canonical server facts', () {
    final String source = File(
      'lib/features/policy/data/services/'
      'firestore_camo_post_login_access_verifier.dart',
    ).readAsStringSync();

    expect(source, contains("collection('commercialAccessV2')"));
    expect(source, contains("doc('current')"));
    expect(source, contains("schemaVersion != 2"));
    expect(source, contains("'camo_monthly_inr_199'"));
    expect(source, contains('_requiredMonthlyPriceInr = 199'));
    expect(source, contains("licenseStatus != 'active'"));
    expect(source, contains("subscriptionStatus != 'active'"));
    expect(source, contains("billingState != 'paid'"));
    expect(source, contains('deviceAllowance is! int'));
    expect(source, contains('deviceAllowance < 1'));
    expect(source, contains('grantedEntitlements == null'));
  });

  test('commercial access expires fail closed at the exact boundary', () {
    final String source = File(
      'lib/features/policy/data/services/'
      'firestore_camo_post_login_access_verifier.dart',
    ).readAsStringSync();

    expect(
      source,
      contains("final DateTime? expiresAt = _dateTime(data['expiresAt']);"),
    );
    expect(source, contains('expiresAt == null'));
    expect(source, contains('!nowUtc.isBefore(expiresAt)'));
  });

  test('base encode and decode entitlements are independently required', () {
    final String source = File(
      'lib/features/policy/data/services/'
      'firestore_camo_post_login_access_verifier.dart',
    ).readAsStringSync();

    expect(source, contains("contains('baseEncoding')"));
    expect(source, contains("contains('baseDecoding')"));
  });
}
