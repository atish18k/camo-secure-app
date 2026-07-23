import 'dart:io';

import 'package:camo/core/authorization_gateway/data/services/firebase_camo_authorization_callable_primitive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production callable identity and region are locked', () {
    expect(
      FirebaseCamoAuthorizationCallablePrimitive.productionRegion,
      'asia-south1',
    );
    expect(
      FirebaseCamoAuthorizationCallablePrimitive.authorizationFunctionName,
      'authorizeOperation',
    );
    expect(
      FirebaseCamoAuthorizationCallablePrimitive.authorizationTimeout,
      const Duration(seconds: 30),
    );
  });

  test('limited-use App Check token remains explicitly enabled', () {
    final String source = File(
      'lib/core/authorization_gateway/data/services/'
      'firebase_camo_authorization_callable_primitive.dart',
    ).readAsStringSync();

    expect(source, contains('limitedUseAppCheckToken: true'));
    expect(source, contains('FirebaseFunctions.instanceFor'));
    expect(source, contains('region: productionRegion'));
    expect(source, isNot(contains('FirebaseFunctions.instance.')));
  });

  test('Firebase exception details are not logged or returned', () {
    final String source = File(
      'lib/core/authorization_gateway/data/services/'
      'camo_v2_authorization_callable_client.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('.details')));
    expect(source, isNot(contains('.message')));
    expect(source, isNot(contains('debugPrint')));
    expect(source, isNot(contains('print(')));
  });
}
