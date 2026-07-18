enum CamoDeviceSupportLevel { fullySupported, limited, unsupported }

final class CamoDeviceSupportAcceptance {
  const CamoDeviceSupportAcceptance({
    required this.supportLevel,
    required this.platformLabel,
    required this.hardwareBackingConfirmed,
    required this.limitedRiskAccepted,
    this.policyVersion = currentPolicyVersion,
  });

  static const String currentPolicyVersion = 'device-support-v1';
  final CamoDeviceSupportLevel supportLevel;
  final String platformLabel;
  final bool hardwareBackingConfirmed;
  final bool limitedRiskAccepted;
  final String policyVersion;

  void validate() {
    if (supportLevel == CamoDeviceSupportLevel.unsupported) {
      throw StateError(
        'Unsupported devices cannot accept CAMO device support.',
      );
    }
    if (supportLevel == CamoDeviceSupportLevel.limited &&
        !limitedRiskAccepted) {
      throw StateError('Limited Support disclosure must be accepted.');
    }
    if (platformLabel.trim().isEmpty || policyVersion != currentPolicyVersion) {
      throw StateError('Device support acceptance is invalid.');
    }
  }
}
