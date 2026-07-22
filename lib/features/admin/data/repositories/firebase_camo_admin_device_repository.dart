import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/entities/camo_admin_device.dart';
import '../../domain/entities/camo_admin_device_request.dart';
import '../../domain/repositories/camo_admin_device_request_repository.dart';

final class FirebaseCamoAdminDeviceRepository
    implements CamoAdminDeviceRequestRepository {
  FirebaseCamoAdminDeviceRepository({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  final FirebaseFunctions _functions;

  Map<String, dynamic> _map(Object? value) {
    if (value is Map) {
      return value.map(
        (Object? key, Object? item) => MapEntry(key.toString(), item),
      );
    }
    throw const FormatException('Invalid admin callable response.');
  }

  List<Map<String, dynamic>> _list(Object? value) {
    if (value is! List) {
      throw const FormatException('Invalid admin callable list.');
    }
    return value.map((Object? item) => _map(item)).toList(growable: false);
  }

  @override
  Future<List<CamoAdminDeviceRequest>> fetchPendingRequests() async {
    final HttpsCallableResult<Object?> result = await _functions
        .httpsCallable('listPendingDeviceRegistrationRequests')
        .call<Object?>();
    final Map<String, dynamic> payload = _map(result.data);
    return _list(
      payload['requests'],
    ).map(CamoAdminDeviceRequest.fromMap).toList(growable: false);
  }

  @override
  Future<void> approveRequest({
    required String userId,
    required String requestId,
  }) async {
    await _functions.httpsCallable('approveDeviceRegistrationRequest').call(
      <String, Object?>{'userId': userId, 'requestId': requestId},
    );
  }

  @override
  Future<void> rejectRequest({
    required String userId,
    required String requestId,
    required String reason,
  }) async {
    await _functions.httpsCallable('rejectDeviceRegistrationRequest').call(
      <String, Object?>{
        'userId': userId,
        'requestId': requestId,
        'reason': reason,
      },
    );
  }

  @override
  Future<List<CamoAdminDevice>> fetchDevices(String userId) async {
    final HttpsCallableResult<Object?> result = await _functions
        .httpsCallable('listAdminUserDevices')
        .call<Object?>(<String, Object?>{'userId': userId});
    final Map<String, dynamic> payload = _map(result.data);
    return _list(
      payload['devices'],
    ).map(CamoAdminDevice.fromMap).toList(growable: false);
  }

  @override
  Future<void> replaceDevice({
    required String userId,
    required String requestId,
    required String previousDeviceId,
    required String reason,
  }) async {
    await _functions
        .httpsCallable('replaceApprovedDevice')
        .call(<String, Object?>{
          'userId': userId,
          'requestId': requestId,
          'previousDeviceId': previousDeviceId,
          'reason': reason,
        });
  }
}
