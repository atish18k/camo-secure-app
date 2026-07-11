import '../entities/camo_authorization_response_acceptance_decision.dart';
import '../entities/camo_authorization_signature_verification_decision.dart';
import '../entities/camo_single_use_authorization_artifact.dart';

abstract interface class CamoAuthorizationResponseAcceptanceService {
  Future<CamoAuthorizationResponseAcceptanceDecision> accept({
    required CamoAuthorizationSignatureVerificationDecision signatureDecision,
    required CamoSingleUseAuthorizationArtifact singleUseArtifact,
  });
}
