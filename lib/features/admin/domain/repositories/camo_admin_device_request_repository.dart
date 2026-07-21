import '../entities/camo_admin_device_request.dart';

abstract interface class CamoAdminDeviceRequestRepository {
  Future<List<CamoAdminDeviceRequest>> fetchPendingRequests();
}
