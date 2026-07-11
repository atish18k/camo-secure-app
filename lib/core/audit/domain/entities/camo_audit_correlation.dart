// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoAuditCorrelation {
  const CamoAuditCorrelation({
    required this.correlationId,
    required this.traceId,
    this.parentEventId,
    this.operationId,
    this.authorizationId,
  });
  final String correlationId;
  final String traceId;
  final String? parentEventId;
  final String? operationId;
  final String? authorizationId;
  bool get isValid {
    return correlationId.isNotEmpty && traceId.isNotEmpty;
  }
}
