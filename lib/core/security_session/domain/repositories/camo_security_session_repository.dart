// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/result/camo_result.dart';
import '../entities/camo_security_session.dart';
import '../entities/camo_security_session_termination_reason.dart';
import '../entities/camo_security_session_validation_context.dart';
import '../entities/camo_security_session_validation_decision.dart';

// -----------------------------------------------------------------------------
// Repository
// -----------------------------------------------------------------------------
abstract interface class CamoSecuritySessionRepository {
  Future<CamoResult<CamoSecuritySession>> createSession(
    CamoSecuritySession session,
  );
  Future<CamoResult<CamoSecuritySessionValidationDecision>> validateSession(
    CamoSecuritySessionValidationContext context,
  );
  Future<CamoResult<void>> consumeSession(String sessionId);
  Future<CamoResult<void>> revokeSession({
    required String sessionId,
    required CamoSecuritySessionTerminationReason reason,
  });
  Future<CamoResult<void>> revokeAllUserSessions({
    required String userId,
    required CamoSecuritySessionTerminationReason reason,
  });
}
