import '../../../../core/licensing/domain/entities/camo_license_status.dart';
import '../../../../core/licensing/domain/entities/camo_subscription_status.dart';

final class CamoSubscriptionViewState {
  const CamoSubscriptionViewState.unavailable()
    : isServerVerified = false,
      planId = null,
      monthlyPriceInr = null,
      licenseStatus = CamoLicenseStatus.unknown,
      subscriptionStatus = CamoSubscriptionStatus.unknown,
      billingState = null,
      deviceAllowance = null,
      renewsAt = null,
      expiresAt = null;

  const CamoSubscriptionViewState.serverVerified({
    required this.planId,
    required this.monthlyPriceInr,
    required this.licenseStatus,
    required this.subscriptionStatus,
    required this.billingState,
    required this.deviceAllowance,
    this.renewsAt,
    this.expiresAt,
  }) : isServerVerified = true;

  final bool isServerVerified;
  final String? planId;
  final int? monthlyPriceInr;
  final CamoLicenseStatus licenseStatus;
  final CamoSubscriptionStatus subscriptionStatus;
  final String? billingState;
  final int? deviceAllowance;
  final DateTime? renewsAt;
  final DateTime? expiresAt;

  bool get hasDisplayableServerFacts {
    return isServerVerified &&
        planId?.trim().isNotEmpty == true &&
        monthlyPriceInr != null &&
        monthlyPriceInr! > 0 &&
        billingState?.trim().isNotEmpty == true &&
        deviceAllowance != null &&
        deviceAllowance! > 0 &&
        licenseStatus != CamoLicenseStatus.unknown &&
        subscriptionStatus != CamoSubscriptionStatus.unknown;
  }
}
