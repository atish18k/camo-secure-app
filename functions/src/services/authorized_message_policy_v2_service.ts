import {
  CamoServerAuthorizationContext,
} from "../domain/authorization_types";
import {
  CamoAuthorizationExecutionResultV2,
} from "../domain/authorization_types_v2";
import {
  CamoMessagePolicyV2LifecycleService,
} from "./message_policy_v2_lifecycle_service";
import {
  CamoServerAuthorizerV2,
} from "./server_authorization_orchestrator_v2";

export interface CamoMessagePolicyActivationGate {
  isMessagePolicyMutationEnabled(): boolean;
}

function deny(reasonCode: string): CamoAuthorizationExecutionResultV2 {
  return Object.freeze({authorized: false, reasonCode});
}

export class AuthorizedMessagePolicyV2Service
implements CamoServerAuthorizerV2 {
  constructor(
    private readonly authorizer: CamoServerAuthorizerV2,
    private readonly lifecycle: CamoMessagePolicyV2LifecycleService,
    private readonly gate: CamoMessagePolicyActivationGate,
  ) {}

  async authorize(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoAuthorizationExecutionResultV2> {
    if (!this.gate.isMessagePolicyMutationEnabled()) {
      return deny("server_message_policy_mutation_not_activated");
    }
    const pairId = context.pairId?.trim();
    const messageId = context.messageId?.trim();
    if (!pairId || !messageId) {
      return deny("server_message_policy_binding_invalid");
    }

    if (context.operationType === "encode") {
      if (context.messageValidity === undefined || context.oneTimeView !== false) {
        return deny("server_encode_message_policy_invalid");
      }
      try {
        await this.lifecycle.reserve({
          messageId,
          pairId,
          senderUserId: context.userId,
          senderDeviceId: context.deviceId,
          operationId: context.operationId,
          validity: context.messageValidity,
        });
      } catch {
        return deny("server_message_policy_reservation_denied");
      }

      let result: CamoAuthorizationExecutionResultV2;
      try {
        result = await this.authorizer.authorize(context);
      } catch {
        try {
          await this.lifecycle.block(messageId, "server_authorizer_failed");
        } catch {}
        return deny("server_authorizer_failed");
      }
      if (!result.authorized || result.signedResponse === undefined) {
        try {
          await this.lifecycle.block(messageId, result.reasonCode);
        } catch {}
        return result;
      }
      try {
        await this.lifecycle.activate(
          messageId,
          result.signedResponse.authorizationId,
          result.signedResponse.signingKeyId,
        );
        return result;
      } catch {
        try {
          await this.lifecycle.block(messageId, "activation_failed");
        } catch {}
        return deny("server_message_policy_activation_denied");
      }
    }

    if (context.operationType === "decode") {
      const result = await this.authorizer.authorize(context);
      if (!result.authorized || result.signedResponse === undefined) return result;
      try {
        await this.lifecycle.consume(messageId);
        return result;
      } catch {
        return deny("server_decode_reservation_denied");
      }
    }

    return deny("server_message_policy_operation_invalid");
  }
}