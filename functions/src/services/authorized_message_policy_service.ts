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

function denied(reasonCode: string): CamoAuthorizationExecutionResult {
  return Object.freeze({authorized: false, reasonCode});
}

export class AuthorizedMessagePolicyService {
  constructor(
    private readonly authorizer: CamoServerAuthorizer,
    private readonly lifecycle: CamoMessagePolicyLifecycleService,
  ) {}

  async authorize(
    context: CamoServerAuthorizationContext,
  ): Promise<CamoAuthorizationExecutionResult> {
    const result = await this.authorizer.authorize(context);
    if (!result.authorized || result.signedResponse === undefined) return result;
    if (context.operationType !== "encode") return result;

    const pairId = context.pairId?.trim();
    const messageId = context.messageId?.trim();
    if (
      !pairId || !messageId || context.messageValidity === undefined ||
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
}
