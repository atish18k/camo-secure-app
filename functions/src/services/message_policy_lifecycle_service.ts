import {
  camoMessagePolicySchemaVersion,
  camoMessagePolicyVersion,
  camoMessageTerminalStatesV1,
  camoMessageValiditiesV1,
  CamoCanonicalMessagePolicyV1,
  CamoMessagePolicyStore,
  CamoMessageTerminalStateV1,
  CamoMessageValidityV1,
} from "../domain/message_policy_types";

const validityMilliseconds: Readonly<Record<
  Exclude<CamoMessageValidityV1, "unlimited">,
  number
>> = Object.freeze({
  five_minutes: 5 * 60_000,
  ten_minutes: 10 * 60_000,
  one_hour: 60 * 60_000,
  four_hours: 4 * 60 * 60_000,
  one_day: 24 * 60 * 60_000,
});

function identifier(value: string, field: string): string {
  const normalized = value.trim();
  if (!normalized || normalized.includes("/")) {
    throw new Error(`invalid_message_policy_${field}`);
  }
  return normalized;
}

export class CamoMessagePolicyLifecycleService {
  constructor(
    private readonly store: CamoMessagePolicyStore,
    private readonly clock: () => Date = () => new Date(),
  ) {}

  async create(input: Readonly<{
    messageId: string; pairId: string; senderUserId: string;
    senderDeviceId: string; validity: CamoMessageValidityV1;
    oneTimeView: boolean;
  }>): Promise<CamoCanonicalMessagePolicyV1> {
    if (!camoMessageValiditiesV1.includes(input.validity)) {
      throw new Error("invalid_message_policy_validity");
    }
    const now = this.clock();
    if (!Number.isFinite(now.getTime())) throw new Error("invalid_server_clock");
    const createdAt = now.toISOString();
    const duration = input.validity === "unlimited"
      ? undefined : validityMilliseconds[input.validity];
    const policy: CamoCanonicalMessagePolicyV1 = Object.freeze({
      schemaVersion: camoMessagePolicySchemaVersion,
      messageId: identifier(input.messageId, "message_id"),
      pairId: identifier(input.pairId, "pair_id"),
      senderUserId: identifier(input.senderUserId, "sender_user_id"),
      senderDeviceId: identifier(input.senderDeviceId, "sender_device_id"),
      state: "active", validity: input.validity,
      oneTimeView: input.oneTimeView,
      policyVersion: camoMessagePolicyVersion,
      requiredPolicyVersion: camoMessagePolicyVersion,
      createdAt, updatedAt: createdAt,
      ...(duration === undefined ? {} : {
        expiresAt: new Date(now.getTime() + duration).toISOString(),
      }),
    });
    if (!await this.store.createIfAbsent(policy)) {
      throw new Error("message_policy_replay_rejected");
    }
    return policy;
  }

  async transition(messageId: string, nextState: CamoMessageTerminalStateV1): Promise<void> {
    if (!camoMessageTerminalStatesV1.includes(nextState)) {
      throw new Error("invalid_message_policy_transition");
    }
    if (nextState === "consumed" && !messageId.trim()) {
      throw new Error("invalid_message_policy_message_id");
    }
    const now = this.clock();
    const changed = await this.store.transitionIfActive(Object.freeze({
      messageId: identifier(messageId, "message_id"),
      nextState, transitionedAt: now.toISOString(),
    }));
    if (!changed) throw new Error("message_policy_transition_rejected");
  }
}