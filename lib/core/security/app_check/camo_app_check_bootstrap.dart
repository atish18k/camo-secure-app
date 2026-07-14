import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

const String _camoRecaptchaEnterpriseSiteKey = String.fromEnvironment(
  'CAMO_RECAPTCHA_ENTERPRISE_SITE_KEY',
);

abstract interface class CamoAppCheckClient {
  Future<void> activateEnterprise({required String siteKey});

  Future<void> setTokenAutoRefreshEnabled(bool enabled);

  Future<String?> getToken({required bool forceRefresh});
}

final class FirebaseCamoAppCheckClient implements CamoAppCheckClient {
  FirebaseCamoAppCheckClient({FirebaseAppCheck? appCheck})
    : _appCheck = appCheck ?? FirebaseAppCheck.instance;

  final FirebaseAppCheck _appCheck;

  @override
  Future<void> activateEnterprise({required String siteKey}) {
    return _appCheck.activate(
      providerWeb: ReCaptchaEnterpriseProvider(siteKey),
    );
  }

  @override
  Future<void> setTokenAutoRefreshEnabled(bool enabled) {
    return _appCheck.setTokenAutoRefreshEnabled(enabled);
  }

  @override
  Future<String?> getToken({required bool forceRefresh}) {
    return _appCheck.getToken(forceRefresh);
  }
}

final class CamoAppCheckBootstrap {
  const CamoAppCheckBootstrap({
    required this.client,
    required this.enterpriseSiteKey,
    required this.isWeb,
  });

  final CamoAppCheckClient client;
  final String enterpriseSiteKey;
  final bool isWeb;

  Future<void> initialize() async {
    if (!isWeb) {
      throw UnsupportedError(
        'CAMO App Check production bootstrap is not configured '
        'for this platform.',
      );
    }

    final String normalizedSiteKey = enterpriseSiteKey.trim();

    if (normalizedSiteKey.isEmpty) {
      throw StateError('CAMO_RECAPTCHA_ENTERPRISE_SITE_KEY is required.');
    }

    await client.activateEnterprise(siteKey: normalizedSiteKey);

    await client.setTokenAutoRefreshEnabled(true);

    final String? token = await client.getToken(forceRefresh: true);

    if (token == null || token.trim().isEmpty) {
      throw StateError('Firebase App Check did not return a valid token.');
    }
  }
}

Future<void> initializeCamoAppCheck() {
  return CamoAppCheckBootstrap(
    client: FirebaseCamoAppCheckClient(),
    enterpriseSiteKey: _camoRecaptchaEnterpriseSiteKey,
    isWeb: kIsWeb,
  ).initialize();
}
