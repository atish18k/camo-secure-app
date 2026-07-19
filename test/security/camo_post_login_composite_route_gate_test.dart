import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every protected route uses device gate then composite server gate', () {
    final String routes = File('lib/app/routes.dart').readAsStringSync();
    final String di = File(
      'lib/core/di/injection_container.dart',
    ).readAsStringSync();

    expect(routes, contains('CamoDeviceApprovalGate('));
    expect(routes, contains('CamoCompositeAccessGate('));
    expect(routes, contains('sl<CamoPostLoginAccessVerifier>()'));

    final int deviceGate = routes.indexOf('CamoDeviceApprovalGate(');
    final int compositeGate = routes.indexOf('CamoCompositeAccessGate(');
    final int protectedChild = routes.indexOf('child: child');

    expect(deviceGate, greaterThanOrEqualTo(0));
    expect(compositeGate, greaterThan(deviceGate));
    expect(protectedChild, greaterThan(compositeGate));

    expect(
      di,
      contains('sl.registerLazySingleton<CamoPostLoginAccessVerifier>('),
    );
    expect(di, contains('FirestoreCamoPostLoginAccessVerifier('));
  });
}
