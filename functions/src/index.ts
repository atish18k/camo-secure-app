import { randomUUID } from "node:crypto";

import { initializeApp } from "firebase-admin/app";
import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { setGlobalOptions } from "firebase-functions/v2";
import { provisionControlledCanaryPair } from "./services/canary_pair_provisioning_service";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
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
type PendingCommercialRequestView = Readonly<{
  requestId: string;
  userId: string;
  userEmail: string | null;
  status: "pending";
  requestedAt: string | null;
}>;

const allowedCommercialApprovalDurations = new Set<number>([1, 3, 7, 10]);

function readCommercialRequestId(value: unknown): string {
  if (typeof value !== "string") {
    throw new HttpsError("invalid-argument", "requestId must be a string.");
  }
  const normalized = value.trim();
  if (
    normalized.length === 0 ||
    normalized.length > 128 ||
    normalized.includes("/") ||
    normalized.includes("\\")
  ) {
    throw new HttpsError("invalid-argument", "requestId is invalid.");
  }
  return normalized;
}

function readCommercialApprovalDuration(value: unknown): number {
  if (
    typeof value !== "number" ||
    !Number.isInteger(value) ||
    !allowedCommercialApprovalDurations.has(value)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "durationDays must be exactly 1, 3, 7, or 10.",
    );
  }
  return value;
}

export const requestCommercialAccess = onCall(
  {
    enforceAppCheck: true,
    consumeAppCheckToken: true,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication is required.");
    }

    const userId = request.auth.uid;
    const userEmail =
      typeof request.auth.token.email === "string"
        ? request.auth.token.email
        : null;
    const requestRef = firestore
      .collection("commercialAccessRequestsV1")
      .doc(userId);

    await firestore.runTransaction(async (transaction) => {
      const existing = await transaction.get(requestRef);
      if (existing.exists && existing.data()?.status === "pending") {
        return;
      }

      transaction.set(
        requestRef,
        {
          schemaVersion: 1,
          userId,
          userEmail,
          status: "pending",
          requestedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: false },
      );
    });

    return Object.freeze({
      success: true,
      requestId: requestRef.id,
      status: "pending",
    });
  },
);

export const listPendingCommercialAccessRequests = onCall(
  {
    enforceAppCheck: true,
    consumeAppCheckToken: true,
  },
  async (request) => {
    assertLockedAdmin(request);

    const snapshot = await firestore
      .collection("commercialAccessRequestsV1")
      .where("status", "==", "pending")
      .limit(100)
      .get();

    const requests: PendingCommercialRequestView[] = snapshot.docs.map((doc) => {
      const data = doc.data();
      const requestedAt =
        data.requestedAt instanceof Timestamp
          ? data.requestedAt.toDate().toISOString()
          : null;

      return Object.freeze({
        requestId: doc.id,
        userId: typeof data.userId === "string" ? data.userId : "",
        userEmail: typeof data.userEmail === "string" ? data.userEmail : null,
        status: "pending" as const,
        requestedAt,
      });
    });

    return Object.freeze({ requests });
  },
);

export const approveCommercialAccessRequest = onCall(
  {
    enforceAppCheck: true,
    consumeAppCheckToken: true,
  },
  async (request) => {
    const adminUid = assertLockedAdmin(request);

    if (
      typeof request.data !== "object" ||
      request.data === null ||
      Array.isArray(request.data)
    ) {
      throw new HttpsError("invalid-argument", "Approval payload is invalid.");
    }

    const payload = request.data as Record<string, unknown>;
    const requestId = readCommercialRequestId(payload.requestId);
    const durationDays = readCommercialApprovalDuration(payload.durationDays);
    const requestRef = firestore
      .collection("commercialAccessRequestsV1")
      .doc(requestId);
    const auditRef = firestore.collection("adminAuditEvents").doc();

    const result = await firestore.runTransaction(async (transaction) => {
      const requestSnapshot = await transaction.get(requestRef);
      if (!requestSnapshot.exists) {
        throw new HttpsError("not-found", "Commercial access request not found.");
      }

      const pending = requestSnapshot.data();
      if (
        pending?.status !== "pending" ||
        typeof pending.userId !== "string" ||
        pending.userId.length === 0 ||
        pending.userId !== requestId
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Commercial access request is not a valid pending request.",
        );
      }

      const now = Timestamp.now();
      const expiresAt = Timestamp.fromMillis(
        now.toMillis() + durationDays * 24 * 60 * 60 * 1000,
      );
      const accessRef = firestore
        .collection("users")
        .doc(pending.userId)
        .collection("commercialAccessV2")
        .doc("current");

      transaction.set(
        accessRef,
        {
          schemaVersion: 2,
          userId: pending.userId,
          planId: "camo_monthly_inr_199",
          monthlyPriceInr: 199,
          licenseStatus: "active",
          subscriptionStatus: "active",
          billingState: "paid",
          deviceAllowance: 1,
          grantedEntitlements: ["baseEncoding", "baseDecoding"],
          startsAt: now,
          expiresAt,
          grantedByAdminUid: adminUid,
          sourceCommercialRequestId: requestId,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: false },
      );

      transaction.update(requestRef, {
        status: "approved",
        approvedDurationDays: durationDays,
        approvedByAdminUid: adminUid,
        approvedAt: now,
        updatedAt: FieldValue.serverTimestamp(),
      });

      transaction.create(auditRef, {
        schemaVersion: 1,
        eventType: "commercial_access_request_approved",
        actorAdminUid: adminUid,
        targetUserId: pending.userId,
        sourceCommercialRequestId: requestId,
        durationDays,
        createdAt: FieldValue.serverTimestamp(),
      });

      return Object.freeze({
        userId: pending.userId as string,
        expiresAt: expiresAt.toDate().toISOString(),
      });
    });

    logger.info("Pending commercial access request approved.", {
      auditEventId: auditRef.id,
      actorAdminUid: adminUid,
      targetUserId: result.userId,
      requestId,
      durationDays,
    });

    return Object.freeze({
      success: true,
      requestId,
      userId: result.userId,
      durationDays,
      expiresAt: result.expiresAt,
      auditEventId: auditRef.id,
    });
  },
);
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
      return {
        requests: await listPendingDeviceRequests(firestore),
      };
    } catch (error) {
      logger.error(
        "listPendingDeviceRegistrationRequests failed.",
        {
          operation: "listPendingDeviceRegistrationRequests",
          actorUid: request.auth?.uid ?? null,
          error:
            error instanceof Error
              ? {
                  name: error.name,
                  message: error.message,
                  stack: error.stack,
                }
              : error,
        },
      );

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
