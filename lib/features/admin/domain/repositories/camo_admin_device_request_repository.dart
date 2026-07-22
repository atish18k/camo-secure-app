import '../entities/camo_admin_device.dart';
import '../entities/camo_admin_device_request.dart';

abstract interface class CamoAdminDeviceRequestRepository {
  Future<List<CamoAdminDeviceRequest>> fetchPendingRequests();

  Future<void> approveRequest({
    required String userId,
    required String requestId,
  });

  Future<void> rejectRequest({
    required String userId,
    required String requestId,
    required String reason,
  });

  Future<List<CamoAdminDevice>> fetchDevices(String userId);

  Future<void> replaceDevice({
    required String userId,
    required String requestId,
    required String previousDeviceId,
    required String reason,
  });
}
