import 'package:flutter_test/flutter_test.dart';

import 'package:camo/core/authorization_gateway/data/services/transport_backed_camo_production_authorization_gateway_adapter.dart';

void main() {
  group(
    'TransportBackedCamoProductionAuthorizationGatewayAdapter',
    () {
      test('production adapter foundation type is available', () {
        expect(
          TransportBackedCamoProductionAuthorizationGatewayAdapter,
          isNotNull,
        );
      });
    },
  );
}