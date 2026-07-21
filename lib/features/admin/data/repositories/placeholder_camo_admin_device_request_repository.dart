import '../../domain/entities/camo_admin_device_request.dart';
import '../../domain/repositories/camo_admin_device_request_repository.dart';

/// Phase 1 read-only placeholder.
///
/// It intentionally returns no privileged data until a dedicated,
/// server-authorized, audited backend read endpoint is connected.
final class PlaceholderCamoAdminDeviceRequestRepository
    implements CamoAdminDeviceRequestRepository {
  const PlaceholderCamoAdminDeviceRequestRepository();

  @override
  Future<List<CamoAdminDeviceRequest>> fetchPendingRequests() async {
    return const <CamoAdminDeviceRequest>[];
  }
}
