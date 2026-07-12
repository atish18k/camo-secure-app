import 'package:camo/core/authorization/data/services/fail_closed_camo_enterprise_authorization_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FailClosedCamoEnterpriseAuthorizationService', () {
    const FailClosedCamoEnterpriseAuthorizationService service =
        FailClosedCamoEnterpriseAuthorizationService();

    test('consumeSession rejects an empty session identifier', () async {
      final result = await service.consumeSession('   ');

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull?.code,
        'authorization_session_id_invalid',
      );
    });

    test('consumeSession fails closed for a non-empty identifier', () async {
      final result = await service.consumeSession('session-001');

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull?.code,
        'authorization_session_consumption_unavailable',
      );
    });
  });
}