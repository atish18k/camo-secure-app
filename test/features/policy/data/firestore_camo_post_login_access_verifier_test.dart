import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('post-login verifier is fresh-server-backed and fail closed', () {
    final String source = File(
      'lib/features/policy/data/services/'
      'firestore_camo_post_login_access_verifier.dart',
    ).readAsStringSync();

    expect(source, contains('GetOptions(source: Source.server)'));
    expect(source, contains("collection('commercialAccessV2')"));
    expect(source, contains("doc('current')"));
    expect(source, contains("'camo_monthly_inr_199'"));
    expect(source, contains('_requiredMonthlyPriceInr = 199'));
    expect(source, contains("licenseStatus != 'active'"));
    expect(source, contains("subscriptionStatus != 'active'"));
    expect(source, contains("billingState != 'paid'"));
    expect(source, contains('server_commercial_access_verification_failed'));
    expect(source, isNot(contains('Source.cache')));
    expect(
      source,
      isNot(contains('CamoPostLoginAccessDecision.allow();\n    } on')),
    );
  });

  test('post-login verifier requires base encode and decode entitlements', () {
    final String source = File(
      'lib/features/policy/data/services/'
      'firestore_camo_post_login_access_verifier.dart',
    ).readAsStringSync();

    expect(source, contains('server_base_encoding_entitlement_missing'));
    expect(source, contains('server_base_decoding_entitlement_missing'));
    expect(source, contains('server_device_commercial_binding_missing'));
  });
}
