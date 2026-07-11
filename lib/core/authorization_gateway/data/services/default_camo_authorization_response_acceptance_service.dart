// ignore_for_file: prefer_initializing_formals

import '../../domain/entities/camo_authorization_response_acceptance_decision.dart';
import '../../domain/entities/camo_authorization_signature_verification_decision.dart';
import '../../domain/entities/camo_single_use_authorization_artifact.dart';
import '../../domain/services/camo_authorization_response_acceptance_service.dart';
import '../../domain/services/camo_single_use_authorization_service.dart';

final class DefaultCamoAuthorizationResponseAcceptanceService
    implements CamoAuthorizationResponseAcceptanceService {
  const DefaultCamoAuthorizationResponseAcceptanceService({
    required CamoSingleUseAuthorizationService singleUseService,
  }) : _singleUseService = singleUseService;

  final CamoSingleUseAuthorizationService _singleUseService;

  @override
  Future<CamoAuthorizationResponseAcceptanceDecision> accept({
    required CamoAuthorizationSignatureVerificationDecision signatureDecision,
    required CamoSingleUseAuthorizationArtifact singleUseArtifact,
  }) async {
    if (!signatureDecision.permitsResponseUse) {
      return CamoAuthorizationResponseAcceptanceDecision.denied(
        signatureDecision.reasonCode.trim().isEmpty
            ? 'authorization_response_signature_not_verified'
            : signatureDecision.reasonCode,
      );
    }

    final consumptionDecision = await _singleUseService.consume(
      singleUseArtifact,
    );

    if (!consumptionDecision.permitsOperation) {
      return CamoAuthorizationResponseAcceptanceDecision.denied(
        consumptionDecision.reasonCode.trim().isEmpty
            ? 'authorization_response_replay_protection_failed'
            : consumptionDecision.reasonCode,
      );
    }

    return const CamoAuthorizationResponseAcceptanceDecision.accepted();
  }
}
