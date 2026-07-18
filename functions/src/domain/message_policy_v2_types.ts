import {CamoMessageValidityV1} from "./message_policy_types";

export const camoMessagePolicySchemaVersionV2 = 2 as const;
export const camoMessagePolicyStatesV2 = Object.freeze([
  "pending", "active", "consumed", "expired", "revoked", "deleted", "burned", "blocked",
] as const);
export type CamoMessagePolicyStateV2 = typeof camoMessagePolicyStatesV2[number];
export const camoMessagePolicyTransitionsV2 = Object.freeze({
  pending: Object.freeze(["active", "blocked", "expired"] as const),
  active: Object.freeze(["consumed", "expired", "revoked", "deleted", "burned", "blocked"] as const),
  consumed: Object.freeze(["deleted"] as const),
  expired: Object.freeze(["deleted"] as const),
  revoked: Object.freeze(["deleted"] as const),
  deleted: Object.freeze([] as const),
  burned: Object.freeze([] as const),
  blocked: Object.freeze([] as const),
});

export interface CamoCanonicalMessagePolicyV2 {
  readonly schemaVersion: 2;
  readonly messageId: string;
  readonly pairId: string;
  readonly senderUserId: string;
  readonly senderDeviceId: string;
  readonly operationId: string;
  readonly state: CamoMessagePolicyStateV2;
  readonly validity: CamoMessageValidityV1;
  readonly oneTimeView: false;
  readonly createdAt: string;
  readonly updatedAt: string;
  readonly pendingExpiresAt: string;
  readonly expiresAt?: string;
  readonly authorizationId?: string;
  readonly signingKeyId?: string;
  readonly failureReasonCode?: string;
}

export interface CamoMessagePolicyStoreV2 {
  reserveIfAbsent(policy: CamoCanonicalMessagePolicyV2): Promise<boolean>;
  transitionIfState(input: Readonly<{
    messageId: string;
    expectedState: "pending" | "active";
    nextState: CamoMessagePolicyStateV2;
    transitionedAt: string;
    authorizationId?: string;
    signingKeyId?: string;
    failureReasonCode?: string;
  }>): Promise<boolean>;
}
