import '../entities/camo_single_use_authorization_artifact.dart';
import '../entities/camo_single_use_consumption_decision.dart';

abstract interface class CamoSingleUseAuthorizationService {
  Future<CamoSingleUseConsumptionDecision> consume(
    CamoSingleUseAuthorizationArtifact artifact,
  );
}
