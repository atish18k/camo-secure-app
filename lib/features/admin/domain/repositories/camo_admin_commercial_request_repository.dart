abstract interface class CamoAdminCommercialRequestRepository {
  Future<List<CamoPendingCommercialRequest>> listPendingRequests();

  Future<CamoApprovedCommercialRequest> approveRequest({
    required String requestId,
    required int durationDays,
  });
}

final class CamoPendingCommercialRequest {
  const CamoPendingCommercialRequest({
    required this.requestId,
    required this.userId,
    required this.status,
    this.userEmail,
    this.requestedAt,
  });

  final String requestId;
  final String userId;
  final String? userEmail;
  final String status;
  final DateTime? requestedAt;
}

final class CamoApprovedCommercialRequest {
  const CamoApprovedCommercialRequest({
    required this.requestId,
    required this.userId,
    required this.durationDays,
    required this.expiresAt,
    required this.auditEventId,
  });

  final String requestId;
  final String userId;
  final int durationDays;
  final DateTime expiresAt;
  final String auditEventId;
}
