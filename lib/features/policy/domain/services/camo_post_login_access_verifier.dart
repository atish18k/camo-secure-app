final class CamoPostLoginAccessDecision {
  const CamoPostLoginAccessDecision._(this.allowed, this.reasonCode);
  const CamoPostLoginAccessDecision.allow()
    : this._(true, 'server_composite_access_valid');
  const CamoPostLoginAccessDecision.deny(String reasonCode)
    : this._(false, reasonCode);
  final bool allowed;
  final String reasonCode;
}

abstract interface class CamoPostLoginAccessVerifier {
  Future<CamoPostLoginAccessDecision> verify();
}
