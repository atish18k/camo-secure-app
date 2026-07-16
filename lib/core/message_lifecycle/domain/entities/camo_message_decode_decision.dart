enum CamoMessageDecodeDenialReason { expired, consumed, revoked, deleted }

final class CamoMessageDecodeDecision {
  const CamoMessageDecodeDecision._({required this.allowed, this.denialReason});

  const CamoMessageDecodeDecision.allowed() : this._(allowed: true);

  const CamoMessageDecodeDecision.denied(CamoMessageDecodeDenialReason reason)
    : this._(allowed: false, denialReason: reason);

  final bool allowed;
  final CamoMessageDecodeDenialReason? denialReason;
}
