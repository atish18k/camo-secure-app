// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoReplayProtectionDecision {
  const CamoReplayProtectionDecision({
    required this.allowed,
    required this.reasonCode,
    required this.evaluatedAt,
  });
  final bool allowed;
  final String reasonCode;
  final DateTime evaluatedAt;
  bool get permitsRequest => allowed;
}
