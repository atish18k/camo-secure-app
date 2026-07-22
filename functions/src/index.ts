import { randomUUID } from "node:crypto";

import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { setGlobalOptions } from "firebase-functions/v2";
import { provisionControlledCanaryPair } from "./services/canary_pair_provisioning_service";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import {
  approveDeviceRegistrationWithAudit,
  listActiveDevices,
  listPendingDeviceRequests,
  parseAdminDeviceTargetInput,
  parseAdminRejectDeviceInput,
  parseAdminReplaceDeviceInput,
  rejectDeviceRegistration,
  replaceDeviceRegistration,
} from "./services/admin_device_administration_service";

import {
  createFailClosedDenial,
  parseAuthorizationInput,
} from "./authorization_contract";
import { CamoServerAuthorizationContext } from "./domain/authorization_types";
import { createCamoProductionServerAuthorizationOrchestrator } from "./services/production_server_authorization_factory";
import { camoProductionSecurityConfig } from "./config/production_security_config";

initializeApp();

setGlobalOptions({
  region: camoProductionSecurityConfig.region,
  serviceAccount: camoProductionSecurityConfig.runtimeServiceAccount,
  maxInstances: 10,
  concurrency: 20,
  timeoutSeconds: 30,
  memory: "256MiB",
});

const firestore = getFirestore();

const lockedCommercialBypassAdminUid = "VSgby7BHaRd1MFplKsBAd2QmV9Z2";
const lockedCommercialBypassAdminEmail = "atish18k@gmail.com";

const lockedAdminUid = "VSgby7BHaRd1MFplKsBAd2QmV9Z2";
const lockedAdminEmail = "atish18k@gmail.com";

function assertLockedAdmin(request: {
  auth?: { uid: string; token: Record<string, unknown> };
  app?: unknown;
}): string {
  if (request.auth === undefined) {
    throw new HttpsError("unauthenticated", "Authenticated admin is required.");
  }
  if (request.app === undefined) {
    throw new HttpsError("failed-precondition", "Valid App Check is required.");
  }
  const email =
    typeof request.auth.token.email === "string"
      ? request.auth.token.email.trim().toLowerCase()
      : "";
  if (
    request.auth.uid !== lockedAdminUid ||
    email !== lockedAdminEmail ||
    request.auth.token.camoAdmin !== true
  ) {
    throw new HttpsError("permission-denied", "Locked CAMO admin is required.");
  }
  return request.auth.uid;
}
const authorizationOrchestrator =
  createCamoProductionServerAuthorizationOrchestrator({
    firestore,
    idGenerator: randomUUID,
  });

export const authorizeOperation = onCall(
  {
    enforceAppCheck: true,
    consumeAppCheckToken: true,
  },
  async (request) => {
    if (request.auth === undefined) {
      throw new HttpsError(
        "unauthenticated",
        "Authenticated CAMO user is required.",
      );
    }

    if (request.app === undefined) {
      throw new HttpsError(
        "failed-precondition",
        "Valid Firebase App Check attestation is required.",
      );
    }

    let input;

    try {
      input = parseAuthorizationInput(request.data);
    } catch {
      throw new HttpsError(
        "invalid-argument",
        "Authorization request payload is invalid.",
      );
    }

    if (input.userId !== request.auth.uid) {
      throw new HttpsError(
        "permission-denied",
        "Authorization user binding failed.",
      );
    }

    const tokenEmail =
      typeof request.auth.token.email === "string"
        ? request.auth.token.email.trim().toLowerCase()
        : "";

    const commercialAccessBypass =
      request.auth.uid === lockedCommercialBypassAdminUid &&
      tokenEmail === lockedCommercialBypassAdminEmail &&
      request.auth.token.camoAdmin === true;

    const context: CamoServerAuthorizationContext = Object.freeze({
      requestId: input.requestId,
      operationId: input.operationId,
      userId: input.userId,
      deviceId: input.deviceId,
      operationType: input.operationType,
      pairId: input.pairId,
      messageId: input.messageId,
      messageValidity: input.messageValidity,
      oneTimeView: input.oneTimeView,
      keyPurpose: input.keyPurpose,
      keyScope: input.keyScope,
      requiredEntitlements: input.requiredEntitlements,
      commercialAccessBypass,
      requestedAt: input.requestedAt,
      serverReceivedAt: new Date().toISOString(),
      payloadDigest: input.payloadDigest,
    });

    let result;

    try {
      result = await authorizationOrchestrator.authorize(context);
    } catch {
      const denial = createFailClosedDenial();

      throw new HttpsError(
        "internal",
        "CAMO authorization pipeline failed closed.",
        denial,
      );
    }

    if (!result.authorized || result.signedResponse === undefined) {
      throw new HttpsError(
        "permission-denied",
        "CAMO server authorization was denied.",
        {
          authorized: false,
          reasonCode: result.reasonCode.trim() || "server_authorization_denied",
          serverTime: new Date().toISOString(),
        },
      );
    }

    return result.signedResponse;
  },
);

export const listPendingDeviceRegistrationRequests = onCall(
  { enforceAppCheck: true, consumeAppCheckToken: true },
  async (request) => {
    assertLockedAdmin(request);
    try {
      return { requests: await listPendingDeviceRequests(firestore) };
    } catch {
      throw new HttpsError(
        "failed-precondition",
        "Pending device request read failed closed.",
      );
    }
  },
);

export const approveDeviceRegistrationRequest = onCall(
  { enforceAppCheck: true, consumeAppCheckToken: true },
  async (request) => {
    const actorUid = assertLockedAdmin(request);
    let input;
    try {
      input = parseAdminDeviceTargetInput(request.data);
    } catch {
      throw new HttpsError("invalid-argument", "Approval payload is invalid.");
    }
    try {
      return await approveDeviceRegistrationWithAudit(
        firestore,
        input,
        actorUid,
      );
    } catch {
      throw new HttpsError(
        "failed-precondition",
        "Device approval failed closed.",
      );
    }
  },
);

export const rejectDeviceRegistrationRequest = onCall(
  { enforceAppCheck: true, consumeAppCheckToken: true },
  async (request) => {
    const actorUid = assertLockedAdmin(request);
    let input;
    try {
      input = parseAdminRejectDeviceInput(request.data);
    } catch {
      throw new HttpsError("invalid-argument", "Rejection payload is invalid.");
    }
    try {
      return await rejectDeviceRegistration(firestore, input, actorUid);
    } catch {
      throw new HttpsError(
        "failed-precondition",
        "Device rejection failed closed.",
      );
    }
  },
);

export const listAdminUserDevices = onCall(
  { enforceAppCheck: true, consumeAppCheckToken: true },
  async (request) => {
    assertLockedAdmin(request);
    try {
      const input = parseAdminDeviceTargetInput({
        userId: (request.data as Record<string, unknown>)?.userId,
        requestId: "read",
      });
      return { devices: await listActiveDevices(firestore, input.userId) };
    } catch {
      throw new HttpsError(
        "failed-precondition",
        "Active device read failed closed.",
      );
    }
  },
);

export const replaceApprovedDevice = onCall(
  { enforceAppCheck: true, consumeAppCheckToken: true },
  async (request) => {
    const actorUid = assertLockedAdmin(request);
    let input;
    try {
      input = parseAdminReplaceDeviceInput(request.data);
    } catch {
      throw new HttpsError(
        "invalid-argument",
        "Replacement payload is invalid.",
      );
    }
    try {
      return await replaceDeviceRegistration(firestore, input, actorUid);
    } catch {
      throw new HttpsError(
        "failed-precondition",
        "Device replacement failed closed.",
      );
    }
  },
);
export const provisionCanaryPair = onCall(
  { enforceAppCheck: true, consumeAppCheckToken: true },
  async (request) => {
    if (request.auth === undefined)
      throw new HttpsError("unauthenticated", "Authentication required.");
    if (request.app === undefined)
      throw new HttpsError("failed-precondition", "Valid App Check required.");
    if (request.app?.alreadyConsumed === true) {
      throw new HttpsError(
        "unauthenticated",
        "Consumed App Check token rejected.",
      );
    }
    if (request.auth.token.camoPairProvisioner !== true)
      throw new HttpsError(
        "permission-denied",
        "Canary provisioner claim required.",
      );
    try {
      return await provisionControlledCanaryPair(firestore, request.auth.uid);
    } catch {
      throw new HttpsError(
        "failed-precondition",
        "Canary provisioning failed closed.",
      );
    }
  },
);
