final class CamoAuthorizationResponseAcceptanceDecision {
  const CamoAuthorizationResponseAcceptanceDecision._({
    required this.accepted,
    required this.reasonCode,
  });

  const CamoAuthorizationResponseAcceptanceDecision.accepted()
    : this._(accepted: true, reasonCode: 'authorization_response_accepted');

  const CamoAuthorizationResponseAcceptanceDecision.denied(String reasonCode)
    : this._(accepted: false, reasonCode: reasonCode);

  final bool accepted;
  final String reasonCode;

  bool get permitsCoordinatorUse {
    return accepted && reasonCode.trim().isNotEmpty;
  }
}
