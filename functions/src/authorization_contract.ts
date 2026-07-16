import {
  camoMessageValiditiesV1,
  CamoMessageValidityV1,
} from "./domain/message_policy_types";

export interface CamoAuthorizationInput {
  readonly requestId: string;
  readonly operationId: string;
  readonly userId: string;
  readonly deviceId: string;
  readonly operationType: "encode" | "decode";
  readonly keyPurpose: string;
  readonly keyScope: string;
  readonly requestedAt: string;
  readonly pairId?: string;
  readonly messageId?: string;
  readonly messageValidity?: CamoMessageValidityV1;
  readonly oneTimeView?: false;
  readonly requiredEntitlements: readonly string[];
  readonly attributes: Readonly<Record<string, string>>;
}

export interface CamoAuthorizationDenial {
  readonly authorized: false;
  readonly reasonCode: string;
  readonly serverTime: string;
}

function requireNonEmptyString(value: unknown, fieldName: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Invalid authorization field: ${fieldName}.`);
  }
  return value.trim();
}

function requireIdentifier(value: unknown, fieldName: string): string {
  const normalized = requireNonEmptyString(value, fieldName);
  if (normalized.includes("/")) {
    throw new Error(`Invalid authorization field: ${fieldName}.`);
  }
  return normalized;
}

function requireStringArray(value: unknown, fieldName: string): readonly string[] {
  if (!Array.isArray(value)) throw new Error(`Invalid authorization field: ${fieldName}.`);
  return Object.freeze(value.map((entry) => requireNonEmptyString(entry, fieldName)));
}

function normalizeAttributes(value: unknown): Readonly<Record<string, string>> {
  if (value === undefined || value === null) return Object.freeze({});
  if (typeof value !== "object" || Array.isArray(value)) {
    throw new Error("Invalid authorization field: attributes.");
  }
  const result: Record<string, string> = {};
  for (const [key, entry] of Object.entries(value)) {
    const normalizedKey = requireNonEmptyString(key, "attributeKey");
    result[normalizedKey] = requireNonEmptyString(entry, `attributes.${normalizedKey}`);
  }
  return Object.freeze(result);
}

export function parseAuthorizationInput(data: unknown): CamoAuthorizationInput {
  if (data === null || typeof data !== "object" || Array.isArray(data)) {
    throw new Error("Authorization request body must be an object.");
  }
  const input = data as Record<string, unknown>;
  const operationType = requireNonEmptyString(input.operationType, "operationType");
  if (operationType !== "encode" && operationType !== "decode") {
    throw new Error("Invalid authorization field: operationType.");
  }
  const pairId = input.pairId === undefined || input.pairId === null
    ? undefined : requireIdentifier(input.pairId, "pairId");
  const messageId = input.messageId === undefined || input.messageId === null
    ? undefined : requireIdentifier(input.messageId, "messageId");

  let messageValidity: CamoMessageValidityV1 | undefined;
  let oneTimeView: false | undefined;
  if (operationType === "encode") {
    if (pairId === undefined || messageId === undefined) {
      throw new Error("Encode authorization requires pairId and messageId.");
    }
    const validity = requireNonEmptyString(input.messageValidity, "messageValidity");
    if (!camoMessageValiditiesV1.includes(validity as CamoMessageValidityV1)) {
      throw new Error("Invalid authorization field: messageValidity.");
    }
    if (input.oneTimeView !== false) {
      throw new Error("oneTimeView is not activated.");
    }
    messageValidity = validity as CamoMessageValidityV1;
    oneTimeView = false;
  } else {
    if (messageId === undefined) throw new Error("Decode authorization requires messageId.");
    if (input.messageValidity !== undefined || input.oneTimeView !== undefined) {
      throw new Error("Decode authorization rejects encode policy fields.");
    }
  }

  return Object.freeze({
    requestId: requireNonEmptyString(input.requestId, "requestId"),
    operationId: requireNonEmptyString(input.operationId, "operationId"),
    userId: requireNonEmptyString(input.userId, "userId"),
    deviceId: requireNonEmptyString(input.deviceId, "deviceId"),
    operationType, keyPurpose: requireNonEmptyString(input.keyPurpose, "keyPurpose"),
    keyScope: requireNonEmptyString(input.keyScope, "keyScope"),
    requestedAt: requireNonEmptyString(input.requestedAt, "requestedAt"),
    pairId, messageId, messageValidity, oneTimeView,
    requiredEntitlements: requireStringArray(input.requiredEntitlements, "requiredEntitlements"),
    attributes: normalizeAttributes(input.attributes),
  });
}

export function createFailClosedDenial(
  clock: () => Date = () => new Date(),
): CamoAuthorizationDenial {
  return Object.freeze({authorized: false,
    reasonCode: "production_authorization_not_activated",
    serverTime: clock().toISOString()});
}
