import 'package:camo/core/authorization_gateway/data/services/fail_closed_camo_production_authorization_gateway_adapter.dart';
import 'package:camo/core/authorization_gateway/domain/services/camo_production_authorization_gateway_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FailClosedCamoProductionAuthorizationGatewayAdapter', () {
    test('implements the production adapter contract', () {
      const adapter =
          FailClosedCamoProductionAuthorizationGatewayAdapter();

      expect(
        adapter,
        isA<CamoProductionAuthorizationGatewayAdapter>(),
      );
    });
  });
}