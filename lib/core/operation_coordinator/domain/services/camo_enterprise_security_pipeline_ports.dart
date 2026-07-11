import '../entities/camo_enterprise_operation_request.dart';

abstract interface class CamoSecuritySessionCoordinatorPort {
  Future<bool> validateSession(CamoEnterpriseOperationRequest request);
}

abstract interface class CamoAuthorizationGatewayCoordinatorPort {
  Future<bool> validateFreshServerAuthorization(
    CamoEnterpriseOperationRequest request,
  );
}

abstract interface class CamoAuthorizationCoordinatorPort {
  Future<bool> authorizeIdentityAndOperation(
    CamoEnterpriseOperationRequest request,
  );
}

abstract interface class CamoPolicyCoordinatorPort {
  Future<bool> evaluatePolicy(CamoEnterpriseOperationRequest request);
}

abstract interface class CamoDeviceTrustCoordinatorPort {
  Future<bool> validateDeviceTrust(CamoEnterpriseOperationRequest request);
}

abstract interface class CamoRiskCoordinatorPort {
  Future<bool> evaluateRisk(CamoEnterpriseOperationRequest request);
}

abstract interface class CamoLicensingCoordinatorPort {
  Future<bool> validateCommercialAccess(CamoEnterpriseOperationRequest request);
}

abstract interface class CamoKmsCoordinatorPort {
  Future<String?> authorizeKeyRelease(CamoEnterpriseOperationRequest request);
}

abstract interface class CamoAuditCoordinatorPort {
  Future<void> recordAuthorizationGranted({
    required CamoEnterpriseOperationRequest request,
    required String authorizationReference,
    required String keyReference,
  });

  Future<void> recordAuthorizationDenied({
    required CamoEnterpriseOperationRequest request,
    required String failedStage,
    required String reason,
  });
}
