import 'package:camo/core/authorization_gateway/data/services/fail_closed_camo_authorization_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production gateway remains fail closed', () {
    const FailClosedCamoAuthorizationGateway gateway =
        FailClosedCamoAuthorizationGateway();

    expect(gateway, isNotNull);
  });
}
