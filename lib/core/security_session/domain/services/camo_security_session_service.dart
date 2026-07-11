// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_security_session.dart';
import '../entities/camo_security_session_termination_reason.dart';
import '../entities/camo_security_session_validation_context.dart';
import '../entities/camo_security_session_validation_decision.dart';

// -----------------------------------------------------------------------------
// Service
// -----------------------------------------------------------------------------
abstract interface class CamoSecuritySessionService {
  Future<CamoResult<CamoSecuritySession>> create(CamoSecuritySession session);
  Future<CamoResult<CamoSecuritySessionValidationDecision>> validate(
    CamoSecuritySessionValidationContext context,
  );
  Future<CamoResult<void>> consume(String sessionId);
  Future<CamoResult<void>> revoke({
    required String sessionId,
    required CamoSecuritySessionTerminationReason reason,
  });
}
