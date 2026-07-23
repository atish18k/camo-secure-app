// ignore_for_file: prefer_initializing_formals

import 'package:camo/core/crypto/encryption/camo_verified_v2_uncamo_runtime.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_execution_context.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_outcome.dart';
import 'package:camo/core/operation_coordinator/domain/entities/camo_enterprise_operation_stage.dart';
import 'package:camo/core/operation_coordinator/domain/services/camo_authorized_operation_executor.dart';
import 'package:camo/core/shared/failures/camo_failure.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';

import '../../domain/entities/camo_workspace_operation_payload.dart';
import '../../domain/repositories/camo_workspace_operation_payload_store.dart';
import '../../domain/services/camo_workspace_crypto_port.dart';

final class DefaultCamoAuthorizedOperationExecutor
    implements CamoAuthorizedOperationExecutor {
  const DefaultCamoAuthorizedOperationExecutor({
    required CamoWorkspaceOperationPayloadStore payloadStore,
    required CamoWorkspaceCryptoPort cryptoPort,
    required DateTime Function() clock,
    CamoVerifiedV2UncamoRuntime? verifiedV2UncamoRuntime,
  }) : _payloadStore = payloadStore,
       _cryptoPort = cryptoPort,
       _verifiedV2UncamoRuntime = verifiedV2UncamoRuntime,
       _clock = clock;

  final CamoWorkspaceOperationPayloadStore _payloadStore;
  final CamoWorkspaceCryptoPort _cryptoPort;
  final CamoVerifiedV2UncamoRuntime? _verifiedV2UncamoRuntime;
  final DateTime Function() _clock;

  @override
  Future<CamoResult<CamoEnterpriseOperationOutcome>> execute(
    CamoEnterpriseOperationExecutionContext context,
  ) async {
    if (!context.permitsExecution) {
      return const CamoError<CamoEnterpriseOperationOutcome>(
        CamoSecurityFailure(
          code: 'authorized_execution_context_invalid',
          message: 'Authorized execution context is invalid.',
        ),
      );
    }

    final String operationId = context.request.authorizationRequest.operationId;

    final CamoWorkspaceOperationPayload? payload = _payloadStore.take(
      operationId,
    );

    if (payload == null || !payload.isValid) {
      return const CamoError<CamoEnterpriseOperationOutcome>(
        CamoSecurityFailure(
          code: 'workspace_operation_payload_missing',
          message: 'Authorized workspace operation payload is unavailable.',
        ),
      );
    }

    if (payload.operationType !=
        context.request.authorizationRequest.operationType) {
      return const CamoError<CamoEnterpriseOperationOutcome>(
        CamoSecurityFailure(
          code: 'workspace_operation_type_mismatch',
          message:
              'Authorized operation type does not match the local payload.',
        ),
      );
    }

    try {
      final String output;

      if (payload.operationType == CamoOperationType.encode) {
        output = await _cryptoPort.encode(
          pairingId: payload.pairingId,
          plainText: payload.plainText!,
          subject: payload.subject,
          camouflageEnabled: payload.camouflageEnabled,
        );
      } else if (payload.operationType == CamoOperationType.decode) {
        final CamoVerifiedV2UncamoRuntime? runtime = _verifiedV2UncamoRuntime;
        final authorization = context.request.authorizationRequest;
        final String messageId = authorization.messageId?.trim() ?? '';
        final String pairingId = authorization.pairId?.trim() ?? '';

        if (runtime == null ||
            !context.hasVerifiedV2Permit ||
            messageId.isEmpty ||
            pairingId.isEmpty ||
            pairingId != payload.pairingId.trim()) {
          return const CamoError<CamoEnterpriseOperationOutcome>(
            CamoSecurityFailure(
              code: 'verified_v2_uncamo_runtime_unavailable',
              message:
                  'Verified V2 Standard UNCAMO runtime is unavailable or unbound.',
            ),
          );
        }

        output = await runtime.decrypt(
          requestId: context.request.requestId,
          operationId: operationId,
          messageId: messageId,
          pairingId: pairingId,
          encodedText: payload.encodedText!,
        );
      } else {
        return const CamoError<CamoEnterpriseOperationOutcome>(
          CamoSecurityFailure(
            code: 'workspace_operation_not_supported',
            message: 'Authorized operation is not supported by Workspace.',
          ),
        );
      }

      if (output.isEmpty) {
        return const CamoError<CamoEnterpriseOperationOutcome>(
          CamoSecurityFailure(
            code: 'workspace_crypto_output_empty',
            message: 'Authorized crypto execution returned an empty result.',
          ),
        );
      }

      return CamoSuccess<CamoEnterpriseOperationOutcome>(
        CamoEnterpriseOperationOutcome(
          operationId: operationId,
          stage: CamoEnterpriseOperationStage.completed,
          securityDecision: CamoSecurityDecision.allow,
          reasonCode: 'authorized_crypto_execution_completed',
          completedAt: _clock(),
          resultReference: output,
        ),
      );
    } catch (_) {
      return const CamoError<CamoEnterpriseOperationOutcome>(
        CamoSecurityFailure(
          code: 'authorized_crypto_execution_failed',
          message: 'Authorized crypto execution failed.',
        ),
      );
    }
  }
}
