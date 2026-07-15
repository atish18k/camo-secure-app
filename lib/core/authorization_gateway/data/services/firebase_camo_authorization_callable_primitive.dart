import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/services/camo_authorization_callable_primitive.dart';

final class FirebaseCamoAuthorizationCallablePrimitive
    implements CamoAuthorizationCallablePrimitive {
  FirebaseCamoAuthorizationCallablePrimitive._(this._functions);

  factory FirebaseCamoAuthorizationCallablePrimitive.production() {
    return FirebaseCamoAuthorizationCallablePrimitive._(
      FirebaseFunctions.instanceFor(region: productionRegion),
    );
  }

  static const String productionRegion = 'asia-south1';
  static const String authorizationFunctionName = 'authorizeOperation';
  static const Duration authorizationTimeout = Duration(seconds: 30);

  final FirebaseFunctions _functions;

  @override
  Future<Object?> call(Map<String, Object?> payload) async {
    if (payload.isEmpty) {
      throw StateError('Authorization callable payload is empty.');
    }

    final HttpsCallable callable = _functions.httpsCallable(
      authorizationFunctionName,
      options: HttpsCallableOptions(
        timeout: authorizationTimeout,
        limitedUseAppCheckToken: true,
      ),
    );

    final HttpsCallableResult<Object?> result = await callable.call<Object?>(
      payload,
    );

    return result.data;
  }
}
