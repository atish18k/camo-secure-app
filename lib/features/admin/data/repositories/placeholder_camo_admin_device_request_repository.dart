import '../../domain/entities/camo_admin_device.dart';
import '../../domain/entities/camo_admin_device_request.dart';
import '../../domain/repositories/camo_admin_device_request_repository.dart';

final class PlaceholderCamoAdminDeviceRequestRepository
    implements CamoAdminDeviceRequestRepository {
  const PlaceholderCamoAdminDeviceRequestRepository();

  UnsupportedError _closed() => UnsupportedError(
    'Placeholder repository is read-only and does not perform privileged admin actions.',
  );

  @override
  Future<List<CamoAdminDeviceRequest>> fetchPendingRequests() async =>
      const <CamoAdminDeviceRequest>[];

  @override
  Future<void> approveRequest({
    required String userId,
    required String requestId,
  }) async => throw _closed();

  @override
  Future<void> rejectRequest({
    required String userId,
    required String requestId,
    required String reason,
  }) async => throw _closed();

  @override
  Future<List<CamoAdminDevice>> fetchDevices(String userId) async =>
      throw _closed();

  @override
  Future<void> replaceDevice({
    required String userId,
    required String requestId,
    required String previousDeviceId,
    required String reason,
  }) async => throw _closed();
}
