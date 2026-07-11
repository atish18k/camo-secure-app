// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../authorization/domain/entities/camo_authorization_pipeline_decision.dart';
import '../../../authorization/domain/services/camo_enterprise_authorization_service.dart';
import '../../../kms/domain/entities/camo_wrapped_key_material.dart';
import '../../../kms/domain/repositories/camo_kms_repository.dart';
import '../../../shared/failures/camo_failure.dart';
import '../../../shared/result/camo_result.dart';
import '../../../shared/types/camo_security_decision.dart';
import '../entities/camo_enterprise_operation_execution_context.dart';
import '../entities/camo_enterprise_operation_outcome.dart';
import '../entities/camo_enterprise_operation_request.dart';
import '../services/camo_authorized_operation_executor.dart';
import '../services/camo_enterprise_operation_coordinator.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class DefaultCamoEnterpriseOperationCoordinator
    implements CamoEnterpriseOperationCoordinator {
  const DefaultCamoEnterpriseOperationCoordinator({
    required this._authorizationService,
    required this._kmsRepository,
    required this._executor,
  });
  final CamoEnterpriseAuthorizationService _authorizationService;
  final CamoKmsRepository _kmsRepository;
  final CamoAuthorizedOperationExecutor _executor;
  @override
  Future<CamoResult<CamoEnterpriseOperationOutcome>> coordinate(
    CamoEnterpriseOperationRequest request,
  ) async {
    if (!request.isValid) {
      return const CamoError<CamoEnterpriseOperationOutcome>(
        CamoValidationFailure(
          code: 'invalid_operation_request',
          message: 'Enterprise operation request is invalid.',
        ),
      );
    }
    final CamoResult<CamoAuthorizationPipelineDecision> authorizationResult =
        await _authorizationService.authorize(request.authorizationRequest);
    if (authorizationResult.isFailure) {
      return CamoError<CamoEnterpriseOperationOutcome>(
        authorizationResult.failureOrNull ??
            const CamoSecurityFailure(
              code: 'authorization_failed',
              message: 'Enterprise authorization failed.',
            ),
      );
    }
    final CamoAuthorizationPipelineDecision? authorizationDecision =
        authorizationResult.valueOrNull;
    if (authorizationDecision == null ||
        !authorizationDecision.permitsOperation) {
      return const CamoError<CamoEnterpriseOperationOutcome>(
        CamoSecurityFailure(
          code: 'operation_not_authorized',
          message: 'Enterprise operation was not authorized.',
        ),
      );
    }
    final CamoResult<CamoWrappedKeyMaterial> wrappedKeyResult =
        await _kmsRepository.releaseWrappedKey(
          authorizationDecision.keyReleaseDecision,
        );
    if (wrappedKeyResult.isFailure) {
      await _authorizationService.consumeSession(
        authorizationDecision.session.sessionId,
      );
      return CamoError<CamoEnterpriseOperationOutcome>(
        wrappedKeyResult.failureOrNull ??
            const CamoSecurityFailure(
              code: 'wrapped_key_release_failed',
              message: 'Wrapped key release failed.',
            ),
      );
    }
    final CamoWrappedKeyMaterial? wrappedKeyMaterial =
        wrappedKeyResult.valueOrNull;
    if (wrappedKeyMaterial == null || !wrappedKeyMaterial.isUsable) {
      await _authorizationService.consumeSession(
        authorizationDecision.session.sessionId,
      );
      return const CamoError<CamoEnterpriseOperationOutcome>(
        CamoSecurityFailure(
          code: 'wrapped_key_invalid',
          message: 'Wrapped key material is invalid or expired.',
        ),
      );
    }
    final CamoEnterpriseOperationExecutionContext executionContext =
        CamoEnterpriseOperationExecutionContext(
          request: request,
          authorizationDecision: authorizationDecision,
          wrappedKeyMaterial: wrappedKeyMaterial,
          authorizedAt: DateTime.now(),
        );
    if (!executionContext.permitsExecution) {
      await _authorizationService.consumeSession(
        authorizationDecision.session.sessionId,
      );
      return const CamoError<CamoEnterpriseOperationOutcome>(
        CamoSecurityFailure(
          code: 'execution_context_invalid',
          message: 'Authorized execution context is invalid.',
        ),
      );
    }
    final CamoResult<CamoEnterpriseOperationOutcome> executionResult =
        await _executor.execute(executionContext);
    final CamoResult<void> sessionConsumeResult = await _authorizationService
        .consumeSession(authorizationDecision.session.sessionId);
    final CamoResult<void> keyConsumeResult = await _kmsRepository
        .consumeKeyRelease(authorizationDecision.keyReleaseDecision.releaseId);
    if (sessionConsumeResult.isFailure || keyConsumeResult.isFailure) {
      return const CamoError<CamoEnterpriseOperationOutcome>(
        CamoSecurityFailure(
          code: 'authorization_consumption_failed',
          message: 'Authorization or key release consumption failed.',
        ),
      );
    }
    if (executionResult.isFailure) {
      return executionResult;
    }
    final CamoEnterpriseOperationOutcome? outcome = executionResult.valueOrNull;
    if (outcome == null || !outcome.isSuccessful) {
      return const CamoError<CamoEnterpriseOperationOutcome>(
        CamoSecurityFailure(
          code: 'operation_execution_failed',
          message: 'Authorized operation execution failed.',
        ),
      );
    }
    return CamoSuccess<CamoEnterpriseOperationOutcome>(
      CamoEnterpriseOperationOutcome(
        operationId: outcome.operationId,
        stage: outcome.stage,
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: outcome.reasonCode,
        completedAt: outcome.completedAt,
        resultReference: outcome.resultReference,
      ),
    );
  }
}
