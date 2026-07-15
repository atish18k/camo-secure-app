export const camoFirestoreContractVersion = 1 as const;

export const camoFirestoreCollectionsV1 = Object.freeze({
  users: "users",
  devices: "devices",
  deviceRegistrationRequests: "deviceRegistrationRequests",
  pairings: "pairings",
  messagePolicies: "messagePolicies",
  enterprisePolicies: "enterprisePolicies",
  enterpriseRiskDecisions: "enterpriseRiskDecisions",
  commercialAccess: "commercialAccess",
  enterpriseAuthorizationConsumptions:
    "enterpriseAuthorizationConsumptions",
});

export const camoUserStatusesV1 = Object.freeze([
  "active",
  "disabled",
] as const);

export const camoDeviceStatusesV1 = Object.freeze([
  "pending",
  "approved",
  "rejected",
  "revoked",
  "blacklisted",
] as const);

export const camoDeviceRegistrationRequestStatusesV1 =
  Object.freeze([
    "pending",
    "approved",
    "rejected",
  ] as const);

export const camoPairStatusesV1 = Object.freeze([
  "pending",
  "active",
  "rejected",
  "revoked",
  "expired",
  "blocked",
] as const);

export const camoMessageLifecycleStatusesV1 =
  Object.freeze([
    "active",
    "expired",
    "revoked",
    "consumed",
    "deleted",
    "burned",
    "blocked",
  ] as const);

export const camoRiskDecisionsV1 = Object.freeze([
  "allow",
  "deny",
  "step_up",
  "manual_review",
] as const);

export const camoDeviceStateTransitionsV1 = Object.freeze({
  pending: Object.freeze([
    "approved",
    "rejected",
    "revoked",
    "blacklisted",
  ]),
  approved: Object.freeze([
    "revoked",
    "blacklisted",
  ]),
  rejected: Object.freeze([]),
  revoked: Object.freeze([
    "blacklisted",
  ]),
  blacklisted: Object.freeze([]),
});

export const camoDeviceRegistrationStateTransitionsV1 =
  Object.freeze({
    pending: Object.freeze([
      "approved",
      "rejected",
    ]),
    approved: Object.freeze([]),
    rejected: Object.freeze([]),
  });

export const camoPairStateTransitionsV1 = Object.freeze({
  pending: Object.freeze([
    "active",
    "rejected",
    "revoked",
    "expired",
    "blocked",
  ]),
  active: Object.freeze([
    "revoked",
    "expired",
    "blocked",
  ]),
  rejected: Object.freeze([]),
  revoked: Object.freeze([]),
  expired: Object.freeze([]),
  blocked: Object.freeze([]),
});

export const camoMessageStateTransitionsV1 = Object.freeze({
  active: Object.freeze([
    "expired",
    "revoked",
    "consumed",
    "deleted",
    "burned",
    "blocked",
  ]),
  expired: Object.freeze([
    "deleted",
  ]),
  revoked: Object.freeze([
    "deleted",
  ]),
  consumed: Object.freeze([
    "deleted",
    "burned",
  ]),
  deleted: Object.freeze([]),
  burned: Object.freeze([]),
  blocked: Object.freeze([
    "revoked",
    "deleted",
  ]),
});

export type CamoFirestoreAuthorityV1 =
  | "client_fact"
  | "server"
  | "server_only";

export interface CamoFirestoreDocumentContractV1 {
  readonly path: string;
  readonly documentId: string;
  readonly owner: string;
  readonly authority: CamoFirestoreAuthorityV1;
  readonly requiredFields: readonly string[];
  readonly optionalFields: readonly string[];
  readonly legacyCompatibilityFields: readonly string[];
}

export const camoFirestoreDocumentsV1 = Object.freeze({
  user: Object.freeze({
    path: "users/{uid}",
    documentId: "Firebase Authentication UID",
    owner: "Authenticated user identity",
    authority: "server",
    requiredFields: Object.freeze([
      "schemaVersion",
      "uid",
      "status",
      "disabled",
      "createdAt",
      "updatedAt",
    ]),
    optionalFields: Object.freeze([
      "camoId",
      "displayName",
      "email",
      "photoUrl",
    ]),
    legacyCompatibilityFields: Object.freeze([]),
  }),

  device: Object.freeze({
    path: "users/{uid}/devices/{deviceId}",
    documentId: "Server-bound device identifier",
    owner: "Firebase UID from parent user document",
    authority: "server_only",
    requiredFields: Object.freeze([
      "schemaVersion",
      "deviceId",
      "userId",
      "publicKey",
      "keyVersion",
      "platform",
      "status",
      "createdAt",
      "updatedAt",
    ]),
    optionalFields: Object.freeze([
      "approvedAt",
      "approvedBy",
      "rejectedAt",
      "revokedAt",
      "blacklistedAt",
      "lastSeenAt",
    ]),
    legacyCompatibilityFields: Object.freeze([
      "approved",
      "revoked",
    ]),
  }),

  deviceRegistrationRequest: Object.freeze({
    path:
      "users/{uid}/deviceRegistrationRequests/{requestId}",
    documentId: "Client-generated unique registration request ID",
    owner: "Authenticated Firebase UID",
    authority: "client_fact",
    requiredFields: Object.freeze([
      "schemaVersion",
      "requestId",
      "userId",
      "deviceId",
      "publicKey",
      "keyVersion",
      "platform",
      "status",
      "requestedAt",
    ]),
    optionalFields: Object.freeze([
      "resolvedAt",
      "resolvedBy",
      "rejectionReason",
    ]),
    legacyCompatibilityFields: Object.freeze([]),
  }),

  pairing: Object.freeze({
    path: "pairings/{pairId}",
    documentId: "Canonical deterministic or server-issued pair ID",
    owner: "Exactly two participant Firebase UIDs",
    authority: "server",
    requiredFields: Object.freeze([
      "schemaVersion",
      "pairId",
      "participantUserIds",
      "status",
      "createdAt",
      "updatedAt",
    ]),
    optionalFields: Object.freeze([
      "requestedBy",
      "acceptedAt",
      "rejectedAt",
      "revokedAt",
      "expiresAt",
      "blockedAt",
    ]),
    legacyCompatibilityFields: Object.freeze([
      "active",
      "senderId",
      "receiverId",
    ]),
  }),

  messagePolicy: Object.freeze({
    path: "messagePolicies/{messageId}",
    documentId: "Authorized encrypted-message identifier",
    owner: "Authorized pair participants",
    authority: "server_only",
    requiredFields: Object.freeze([
      "schemaVersion",
      "messageId",
      "pairId",
      "state",
      "policyVersion",
      "requiredPolicyVersion",
      "createdAt",
      "updatedAt",
    ]),
    optionalFields: Object.freeze([
      "expiresAt",
      "revokedAt",
      "consumedAt",
      "deletedAt",
      "burnedAt",
      "blockedAt",
    ]),
    legacyCompatibilityFields: Object.freeze([
      "expired",
      "burned",
      "deleted",
      "revoked",
      "blocked",
    ]),
  }),

  enterprisePolicy: Object.freeze({
    path: "enterprisePolicies/global",
    documentId: "global",
    owner: "CAMO server authority",
    authority: "server_only",
    requiredFields: Object.freeze([
      "schemaVersion",
      "policyVersion",
      "enabled",
      "onlineAuthorizationRequired",
      "offlineOperationsAllowed",
      "allowedOperations",
      "updatedAt",
    ]),
    optionalFields: Object.freeze([]),
    legacyCompatibilityFields: Object.freeze([]),
  }),

  riskDecision: Object.freeze({
    path: "enterpriseRiskDecisions/{operationId}",
    documentId: "Authorization operation ID",
    owner: "CAMO Risk Engine",
    authority: "server_only",
    requiredFields: Object.freeze([
      "schemaVersion",
      "operationId",
      "userId",
      "deviceId",
      "decision",
      "permitsOperation",
      "createdAt",
      "expiresAt",
    ]),
    optionalFields: Object.freeze([
      "pairId",
      "messageId",
      "riskLevel",
      "reasonCodes",
    ]),
    legacyCompatibilityFields: Object.freeze([]),
  }),

  commercialAccess: Object.freeze({
    path: "users/{uid}/commercialAccess/current",
    documentId: "current",
    owner: "CAMO commercial authority",
    authority: "server_only",
    requiredFields: Object.freeze([
      "schemaVersion",
      "userId",
      "subscriptionActive",
      "grantedEntitlements",
      "expiresAt",
      "updatedAt",
    ]),
    optionalFields: Object.freeze([
      "planId",
      "subscriptionProvider",
    ]),
    legacyCompatibilityFields: Object.freeze([]),
  }),

  authorizationConsumption: Object.freeze({
    path:
      "enterpriseAuthorizationConsumptions/{authorizationId}",
    documentId: "Signed authorization ID",
    owner: "CAMO authorization server",
    authority: "server_only",
    requiredFields: Object.freeze([
      "schemaVersion",
      "authorizationId",
      "requestId",
      "operationId",
      "userId",
      "deviceId",
      "operationType",
      "issuedAt",
      "expiresAt",
      "consumedAt",
    ]),
    optionalFields: Object.freeze([
      "pairId",
      "messageId",
    ]),
    legacyCompatibilityFields: Object.freeze([]),
  }),
} satisfies Readonly<
  Record<string, CamoFirestoreDocumentContractV1>
>);

function requireDocumentSegment(
  value: string,
  segmentName: string,
): string {
  const normalized = value.trim();

  if (
    normalized.length === 0 ||
    normalized.includes("/")
  ) {
    throw new Error(
      `Invalid Firestore document segment: ${segmentName}.`,
    );
  }

  return normalized;
}

export const camoFirestorePathsV1 = Object.freeze({
  user(uid: string): string {
    return `users/${requireDocumentSegment(uid, "uid")}`;
  },

  device(uid: string, deviceId: string): string {
    return [
      "users",
      requireDocumentSegment(uid, "uid"),
      "devices",
      requireDocumentSegment(deviceId, "deviceId"),
    ].join("/");
  },

  deviceRegistrationRequest(
    uid: string,
    requestId: string,
  ): string {
    return [
      "users",
      requireDocumentSegment(uid, "uid"),
      "deviceRegistrationRequests",
      requireDocumentSegment(requestId, "requestId"),
    ].join("/");
  },

  pairing(pairId: string): string {
    return `pairings/${
      requireDocumentSegment(pairId, "pairId")
    }`;
  },

  messagePolicy(messageId: string): string {
    return `messagePolicies/${
      requireDocumentSegment(messageId, "messageId")
    }`;
  },

  enterprisePolicy(): string {
    return "enterprisePolicies/global";
  },

  riskDecision(operationId: string): string {
    return `enterpriseRiskDecisions/${
      requireDocumentSegment(operationId, "operationId")
    }`;
  },

  commercialAccess(uid: string): string {
    return [
      "users",
      requireDocumentSegment(uid, "uid"),
      "commercialAccess",
      "current",
    ].join("/");
  },

  authorizationConsumption(
    authorizationId: string,
  ): string {
    return [
      "enterpriseAuthorizationConsumptions",
      requireDocumentSegment(
        authorizationId,
        "authorizationId",
      ),
    ].join("/");
  },
});
