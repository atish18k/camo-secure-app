abstract interface class CamoCommercialAccessRequestRepository {
  Future<CamoCommercialAccessRequestResult> requestAccess();
}

final class CamoCommercialAccessRequestResult {
  const CamoCommercialAccessRequestResult({
    required this.requestId,
    required this.status,
  });

  final String requestId;
  final String status;

  bool get isPending => status == 'pending';
}
