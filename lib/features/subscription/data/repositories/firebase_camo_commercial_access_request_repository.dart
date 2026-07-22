import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/repositories/camo_commercial_access_request_repository.dart';

final class FirebaseCamoCommercialAccessRequestRepository
    implements CamoCommercialAccessRequestRepository {
  FirebaseCamoCommercialAccessRequestRepository({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  final FirebaseFunctions _functions;

  @override
  Future<CamoCommercialAccessRequestResult> requestAccess() async {
    final HttpsCallableResult<Object?> result = await _functions
        .httpsCallable('requestCommercialAccess')
        .call<Object?>(const <String, Object?>{});

    final Object? raw = result.data;
    if (raw is! Map) {
      throw const FormatException(
        'requestCommercialAccess returned a non-map response.',
      );
    }

    final Object? success = raw['success'];
    final Object? requestId = raw['requestId'];
    final Object? status = raw['status'];

    if (success != true ||
        requestId is! String ||
        requestId.trim().isEmpty ||
        status != 'pending') {
      throw const FormatException(
        'requestCommercialAccess returned an invalid response contract.',
      );
    }

    return CamoCommercialAccessRequestResult(
      requestId: requestId.trim(),
      status: status as String,
    );
  }
}
