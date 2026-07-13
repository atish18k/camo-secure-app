import '../../domain/entities/camo_enterprise_operation_request.dart';
import '../../domain/services/camo_enterprise_security_pipeline_ports.dart';

final class FailClosedCamoSecuritySessionCoordinatorPort
    implements CamoSecuritySessionCoordinatorPort {
  const FailClosedCamoSecuritySessionCoordinatorPort();

  @override
  Future<bool> validateSession(CamoEnterpriseOperationRequest request) async {
    return false;
  }
}

final class FailClosedCamoAuthorizationGatewayCoordinatorPort
    implements CamoAuthorizationGatewayCoordinatorPort {
  const FailClosedCamoAuthorizationGatewayCoordinatorPort();

  @override
  Future<bool> validateFreshServerAuthorization(
    CamoEnterpriseOperationRequest request,
  ) async {
    return false;
  }
}

final class FailClosedCamoAuthorizationCoordinatorPort
    implements CamoAuthorizationCoordinatorPort {
  const FailClosedCamoAuthorizationCoordinatorPort();

  @override
  Future<bool> authorizeIdentityAndOperation(
    CamoEnterpriseOperationRequest request,
  ) async {
    return false;
  }
}

final class FailClosedCamoPolicyCoordinatorPort
    implements CamoPolicyCoordinatorPort {
  const FailClosedCamoPolicyCoordinatorPort();

  @override
  Future<bool> evaluatePolicy(CamoEnterpriseOperationRequest request) async {
    return false;
  }
}

final class FailClosedCamoDeviceTrustCoordinatorPort
    implements CamoDeviceTrustCoordinatorPort {
  const FailClosedCamoDeviceTrustCoordinatorPort();

  @override
  Future<bool> validateDeviceTrust(
    CamoEnterpriseOperationRequest request,
  ) async {
    return false;
  }
}

final class FailClosedCamoRiskCoordinatorPort
    implements CamoRiskCoordinatorPort {
  const FailClosedCamoRiskCoordinatorPort();

  @override
  Future<bool> evaluateRisk(CamoEnterpriseOperationRequest request) async {
    return false;
  }
}

final class FailClosedCamoLicensingCoordinatorPort
    implements CamoLicensingCoordinatorPort {
  const FailClosedCamoLicensingCoordinatorPort();

  @override
  Future<bool> validateCommercialAccess(
    CamoEnterpriseOperationRequest request,
  ) async {
    return false;
  }
}

final class FailClosedCamoKmsCoordinatorPort implements CamoKmsCoordinatorPort {
  const FailClosedCamoKmsCoordinatorPort();

  @override
  Future<String?> authorizeKeyRelease(
    CamoEnterpriseOperationRequest request,
  ) async {
    return null;
  }
}

final class FailClosedCamoAuditCoordinatorPort
    implements CamoAuditCoordinatorPort {
  const FailClosedCamoAuditCoordinatorPort();

  @override
  Future<void> recordAuthorizationGranted({
    required CamoEnterpriseOperationRequest request,
    required String authorizationReference,
    required String keyReference,
  }) async {}

  @override
  Future<void> recordAuthorizationDenied({
    required CamoEnterpriseOperationRequest request,
    required String failedStage,
    required String reason,
  }) async {}
}
