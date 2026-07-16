export const camoMessagePolicySchemaVersion = 1 as const;
export const camoMessagePolicyVersion = 1 as const;

export const camoMessageValiditiesV1 = Object.freeze([
  "five_minutes", "ten_minutes", "one_hour",
  "four_hours", "one_day", "unlimited",
] as const);

export type CamoMessageValidityV1 =
  typeof camoMessageValiditiesV1[number];

export const camoMessageTerminalStatesV1 = Object.freeze([
  "expired", "revoked", "consumed", "deleted", "burned", "blocked",
] as const);

export type CamoMessageTerminalStateV1 =
  typeof camoMessageTerminalStatesV1[number];

export interface CamoCanonicalMessagePolicyV1 {
  readonly schemaVersion: 1;
  readonly messageId: string;
  readonly pairId: string;
  readonly senderUserId: string;
  readonly senderDeviceId: string;
  readonly state: "active";
  readonly validity: CamoMessageValidityV1;
  readonly oneTimeView: boolean;
  readonly policyVersion: 1;
  readonly requiredPolicyVersion: 1;
  readonly createdAt: string;
  readonly updatedAt: string;
  readonly expiresAt?: string;
}

export interface CamoMessagePolicyStore {
  createIfAbsent(policy: CamoCanonicalMessagePolicyV1): Promise<boolean>;
  transitionIfActive(input: Readonly<{
    messageId: string;
    nextState: CamoMessageTerminalStateV1;
    transitionedAt: string;
  }>): Promise<boolean>;
}