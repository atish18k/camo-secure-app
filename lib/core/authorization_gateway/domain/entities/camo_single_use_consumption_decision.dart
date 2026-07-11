final class CamoSingleUseConsumptionDecision {
  const CamoSingleUseConsumptionDecision._({
    required this.consumed,
    required this.reasonCode,
  });

  const CamoSingleUseConsumptionDecision.consumed()
    : this._(consumed: true, reasonCode: 'single_use_authorization_consumed');

  const CamoSingleUseConsumptionDecision.denied(String reasonCode)
    : this._(consumed: false, reasonCode: reasonCode);

  final bool consumed;
  final String reasonCode;

  bool get permitsOperation {
    return consumed && reasonCode.trim().isNotEmpty;
  }
}
