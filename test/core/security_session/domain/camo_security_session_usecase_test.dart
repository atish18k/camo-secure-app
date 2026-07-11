// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/security_session/domain/entities/camo_security_session.dart';
import 'package:camo/core/security_session/domain/entities/camo_security_session_scope.dart';
import 'package:camo/core/security_session/domain/entities/camo_security_session_status.dart';
import 'package:camo/core/security_session/domain/entities/camo_security_session_termination_reason.dart';
import 'package:camo/core/security_session/domain/entities/camo_security_session_validation_context.dart';
import 'package:camo/core/security_session/domain/entities/camo_security_session_validation_decision.dart';
import 'package:camo/core/security_session/domain/repositories/camo_security_session_repository.dart';
import 'package:camo/core/security_session/domain/usecases/validate_camo_security_session_usecase.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Fake Repository
// -----------------------------------------------------------------------------
final class _FakeSecuritySessionRepository
    implements CamoSecuritySessionRepository {
  @override
  Future<CamoResult<CamoSecuritySession>> createSession(
    CamoSecuritySession session,
  ) async {
    return CamoSuccess<CamoSecuritySession>(session);
  }

  @override
  Future<CamoResult<CamoSecuritySessionValidationDecision>> validateSession(
    CamoSecuritySessionValidationContext context,
  ) async {
    final DateTime now = DateTime.now();
    return CamoSuccess<CamoSecuritySessionValidationDecision>(
      CamoSecuritySessionValidationDecision(
        decisionId: 'decision-001',
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: 'session_valid',
        session: CamoSecuritySession(
          sessionId: context.sessionId,
          userId: context.userId,
          deviceId: context.deviceId,
          scope: CamoSecuritySessionScope.operation,
          status: CamoSecuritySessionStatus.active,
          createdAt: now,
          expiresAt: now.add(const Duration(seconds: 30)),
          lastValidatedAt: now,
          singleUse: true,
          operationId: context.operationId,
          authorizationId: context.authorizationId,
          messageId: context.messageId,
          pairId: context.pairId,
        ),
        evaluatedAt: now,
        expiresAt: now.add(const Duration(seconds: 20)),
        stepUpRequired: false,
      ),
    );
  }

  @override
  Future<CamoResult<void>> consumeSession(String sessionId) async {
    return const CamoSuccess<void>(null);
  }

  @override
  Future<CamoResult<void>> revokeSession({
    required String sessionId,
    required CamoSecuritySessionTerminationReason reason,
  }) async {
    return const CamoSuccess<void>(null);
  }

  @override
  Future<CamoResult<void>> revokeAllUserSessions({
    required String userId,
    required CamoSecuritySessionTerminationReason reason,
  }) async {
    return const CamoSuccess<void>(null);
  }
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('validate session use case delegates to repository', () async {
    final ValidateCamoSecuritySessionUseCase useCase =
        ValidateCamoSecuritySessionUseCase(_FakeSecuritySessionRepository());
    final CamoSecuritySessionValidationContext context =
        CamoSecuritySessionValidationContext(
          sessionId: 'session-001',
          userId: 'user-001',
          deviceId: 'device-001',
          operationType: CamoOperationType.encode,
          validatedAt: DateTime.now(),
          operationId: 'operation-001',
          authorizationId: 'authorization-001',
        );
    final CamoResult<CamoSecuritySessionValidationDecision> result =
        await useCase(context);
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.permitsOperation, isTrue);
  });
}
