import {
  CamoAuthorizationExecutionResult,
  CamoServerAuthorizationContext,
} from "../domain/authorization_types";
import {CamoMessagePolicyLifecycleService} from "./message_policy_lifecycle_service";

export interface CamoServerAuthorizer {
  authorize(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoAuthorizationExecutionResult>;
}

export interface CamoMessagePolicyActivationGate {
  isMessagePolicyMutationEnabled(): boolean;
}

function denied(reasonCode: string): CamoAuthorizationExecutionResult {
  return Object.freeze({authorized: false, reasonCode});
}

export class AuthorizedMessagePolicyService implements CamoServerAuthorizer {
  constructor(
    private readonly authorizer: CamoServerAuthorizer,
    private readonly lifecycle: CamoMessagePolicyLifecycleService,
    private readonly activationGate: CamoMessagePolicyActivationGate,
  ) {}

  async authorize(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoAuthorizationExecutionResult> {
    if (!this.activationGate.isMessagePolicyMutationEnabled()) {
      return denied("server_message_policy_mutation_not_activated");
    }

    const pairId = context.pairId?.trim();
    const messageId = context.messageId?.trim();
    if (!pairId || !messageId) {
      return denied("server_message_policy_binding_invalid");
    }

    const result = await this.authorizer.authorize(context);
    if (!result.authorized || result.signedResponse === undefined) return result;

    if (context.operationType === "encode") {
      if (
        context.messageValidity === undefined ||
        context.oneTimeView !== false
      ) return denied("server_encode_message_policy_invalid");

      try {
        await this.lifecycle.create(Object.freeze({
          messageId,
          pairId,
          senderUserId: context.userId,
          senderDeviceId: context.deviceId,
          validity: context.messageValidity,
          oneTimeView: false,
        }));
        return result;
      } catch {
        return denied("server_message_policy_creation_denied");
      }
    }

    if (context.operationType === "decode") {
      try {
        await this.lifecycle.transition(messageId, "consumed");
        return result;
      } catch {
        return denied("server_decode_reservation_denied");
      }
    }

    return denied("server_message_policy_operation_invalid");
  }
}