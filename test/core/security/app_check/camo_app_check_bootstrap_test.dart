import 'package:camo/core/security/app_check/camo_app_check_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeAppCheckClient implements CamoAppCheckClient {
  _FakeAppCheckClient({this.token = 'verified-app-check-token'});

  String? token;
  final List<String> calls = <String>[];

  @override
  Future<void> activateEnterprise({required String siteKey}) async {
    calls.add('activate:$siteKey');
  }

  @override
  Future<void> setTokenAutoRefreshEnabled(bool enabled) async {
    calls.add('autoRefresh:$enabled');
  }

  @override
  Future<String?> getToken({required bool forceRefresh}) async {
    calls.add('getToken:$forceRefresh');
    return token;
  }
}

void main() {
  test('valid web configuration initializes in locked order', () async {
    final _FakeAppCheckClient client = _FakeAppCheckClient();

    await CamoAppCheckBootstrap(
      client: client,
      enterpriseSiteKey: ' enterprise-site-key ',
      isWeb: true,
    ).initialize();

    expect(client.calls, <String>[
      'activate:enterprise-site-key',
      'autoRefresh:true',
      'getToken:true',
    ]);
  });

  test('missing site key fails before provider activation', () async {
    final _FakeAppCheckClient client = _FakeAppCheckClient();

    await expectLater(
      CamoAppCheckBootstrap(
        client: client,
        enterpriseSiteKey: '   ',
        isWeb: true,
      ).initialize(),
      throwsStateError,
    );

    expect(client.calls, isEmpty);
  });

  test('unsupported platform fails before provider activation', () async {
    final _FakeAppCheckClient client = _FakeAppCheckClient();

    await expectLater(
      CamoAppCheckBootstrap(
        client: client,
        enterpriseSiteKey: 'enterprise-site-key',
        isWeb: false,
      ).initialize(),
      throwsUnsupportedError,
    );

    expect(client.calls, isEmpty);
  });

  test('missing App Check token fails closed', () async {
    final _FakeAppCheckClient client = _FakeAppCheckClient(token: null);

    await expectLater(
      CamoAppCheckBootstrap(
        client: client,
        enterpriseSiteKey: 'enterprise-site-key',
        isWeb: true,
      ).initialize(),
      throwsStateError,
    );

    expect(client.calls, <String>[
      'activate:enterprise-site-key',
      'autoRefresh:true',
      'getToken:true',
    ]);
  });

  test('blank App Check token fails closed', () async {
    final _FakeAppCheckClient client = _FakeAppCheckClient(token: '   ');

    await expectLater(
      CamoAppCheckBootstrap(
        client: client,
        enterpriseSiteKey: 'enterprise-site-key',
        isWeb: true,
      ).initialize(),
      throwsStateError,
    );
  });
}
