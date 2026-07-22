import { randomUUID } from "node:crypto";

import {
  FieldValue,
  Firestore,
  QueryDocumentSnapshot,
  Timestamp,
} from "firebase-admin/firestore";

import {
  approveDeviceRegistration,
  DeviceApprovalResult,
} from "./device_registration_approval_service";

export interface AdminDeviceTargetInput {
  readonly userId: string;
  readonly requestId: string;
}

export interface AdminRejectDeviceInput extends AdminDeviceTargetInput {
  readonly reason: string;
}

export interface AdminReplaceDeviceInput extends AdminDeviceTargetInput {
  readonly previousDeviceId: string;
  readonly reason: string;
}

function requiredSegment(value: unknown, name: string): string {
  if (
    typeof value !== "string" ||
    value.trim().length === 0 ||
    value.includes("/")
  ) {
    throw new Error("Invalid " + name + ".");
  }
  return value.trim();
}

function requiredReason(value: unknown): string {
  if (typeof value !== "string") throw new Error("Invalid reason.");
  const reason = value.trim();
  if (reason.length < 3 || reason.length > 200) {
    throw new Error("Reason must be 3..200 characters.");
  }
  return reason;
}

function record(value: unknown): Record<string, unknown> {
  if (value === null || typeof value !== "object" || Array.isArray(value)) {
    throw new Error("Invalid payload.");
  }
  return value as Record<string, unknown>;
}

export function parseAdminDeviceTargetInput(
  value: unknown,
): AdminDeviceTargetInput {
  const data = record(value);
  return Object.freeze({
    userId: requiredSegment(data.userId, "userId"),
    requestId: requiredSegment(data.requestId, "requestId"),
  });
}

export function parseAdminRejectDeviceInput(
  value: unknown,
): AdminRejectDeviceInput {
  const data = record(value);
  return Object.freeze({
    userId: requiredSegment(data.userId, "userId"),
    requestId: requiredSegment(data.requestId, "requestId"),
    reason: requiredReason(data.reason),
  });
}

export function parseAdminReplaceDeviceInput(
  value: unknown,
): AdminReplaceDeviceInput {
  const data = record(value);
  return Object.freeze({
    userId: requiredSegment(data.userId, "userId"),
    requestId: requiredSegment(data.requestId, "requestId"),
    previousDeviceId: requiredSegment(
      data.previousDeviceId,
      "previousDeviceId",
    ),
    reason: requiredReason(data.reason),
  });
}

function timestampIso(value: unknown): string {
  if (value instanceof Timestamp) return value.toDate().toISOString();
  if (typeof value === "string" && Number.isFinite(Date.parse(value))) {
    return new Date(value).toISOString();
  }
  return "";
}

function optionalString(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

async function userIdentity(
  firestore: Firestore,
  userId: string,
): Promise<{ email: string; displayName: string }> {
  const snapshot = await firestore.doc("users/" + userId).get();
  const data = snapshot.data() ?? {};
  return {
    email: optionalString(data.email),
    displayName: optionalString(data.displayName),
  };
}

function requestDto(
  snapshot: QueryDocumentSnapshot,
  identity: { email: string; displayName: string },
): Readonly<Record<string, unknown>> {
  const data = snapshot.data();
  return Object.freeze({
    requestId: optionalString(data.requestId) || snapshot.id,
    userId: optionalString(data.userId),
    userEmail: identity.email,
    deviceId: optionalString(data.deviceId),
    deviceLabel:
      identity.displayName || optionalString(data.platform) || "Device",
    platform: optionalString(data.platform),
    requestedAt: timestampIso(data.requestedAt),
    status: optionalString(data.status),
  });
}

function deviceDto(
  snapshot: QueryDocumentSnapshot,
): Readonly<Record<string, unknown>> {
  const data = snapshot.data();
  return Object.freeze({
    userId: optionalString(data.userId),
    deviceId: optionalString(data.deviceId) || snapshot.id,
    platform: optionalString(data.platform),
    status: optionalString(data.status),
    approvedAt: timestampIso(data.approvedAt),
    revokedAt: timestampIso(data.revokedAt),
    lastSeenAt: timestampIso(data.lastSeenAt),
  });
}

async function writeAudit(
  firestore: Firestore,
  actorUid: string,
  action: string,
  targetUserId: string,
  details: Readonly<Record<string, unknown>>,
): Promise<void> {
  await firestore.collection("adminAuditEvents").doc(randomUUID()).create({
    schemaVersion: 1,
    actorUid,
    action,
    targetUserId,
    details,
    createdAt: FieldValue.serverTimestamp(),
    immutable: true,
  });
}

export async function listPendingDeviceRequests(
  firestore: Firestore,
): Promise<ReadonlyArray<Readonly<Record<string, unknown>>>> {
  const snapshot = await firestore
    .collectionGroup("deviceRegistrationRequests")
    .where("status", "==", "pending")
    .limit(100)
    .get();

  const identities = new Map<string, { email: string; displayName: string }>();
  const result: Array<Readonly<Record<string, unknown>>> = [];

  for (const document of snapshot.docs) {
    const data = document.data();
    const userId = requiredSegment(data.userId, "userId");
    let identity = identities.get(userId);
    if (identity === undefined) {
      identity = await userIdentity(firestore, userId);
      identities.set(userId, identity);
    }
    result.push(requestDto(document, identity));
  }

  return Object.freeze(result);
}

export async function listActiveDevices(
  firestore: Firestore,
  userIdValue: unknown,
): Promise<ReadonlyArray<Readonly<Record<string, unknown>>>> {
  const userId = requiredSegment(userIdValue, "userId");
  const snapshot = await firestore
    .collection("users/" + userId + "/devices")
    .where("status", "in", ["approved", "revoked"])
    .limit(50)
    .get();

  return Object.freeze(snapshot.docs.map(deviceDto));
}

export async function rejectDeviceRegistration(
  firestore: Firestore,
  input: AdminRejectDeviceInput,
  actorUid: string,
): Promise<Readonly<Record<string, unknown>>> {
  const reference = firestore.doc(
    "users/" + input.userId + "/deviceRegistrationRequests/" + input.requestId,
  );

  await firestore.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(reference);
    if (!snapshot.exists) throw new Error("Request not found.");
    const data = snapshot.data() ?? {};
    if (
      data.schemaVersion !== 1 ||
      data.userId !== input.userId ||
      data.requestId !== input.requestId ||
      data.status !== "pending"
    ) {
      throw new Error("Request is not rejectable.");
    }
    transaction.update(reference, {
      status: "rejected",
      rejectionReason: input.reason,
      resolvedAt: FieldValue.serverTimestamp(),
      resolvedBy: actorUid,
    });
  });

  await writeAudit(
    firestore,
    actorUid,
    "device_request_rejected",
    input.userId,
    { requestId: input.requestId, reason: input.reason },
  );

  return Object.freeze({
    userId: input.userId,
    requestId: input.requestId,
    status: "rejected",
  });
}

export async function approveDeviceRegistrationWithAudit(
  firestore: Firestore,
  input: AdminDeviceTargetInput,
  actorUid: string,
): Promise<DeviceApprovalResult> {
  const result = await approveDeviceRegistration(firestore, input, actorUid);
  await writeAudit(
    firestore,
    actorUid,
    "device_request_approved",
    input.userId,
    {
      requestId: input.requestId,
      deviceId: result.deviceId,
      supersededRequestCount: result.supersededRequestCount,
    },
  );
  return result;
}

export async function replaceDeviceRegistration(
  firestore: Firestore,
  input: AdminReplaceDeviceInput,
  actorUid: string,
): Promise<Readonly<Record<string, unknown>>> {
  const requestReference = firestore.doc(
    "users/" + input.userId + "/deviceRegistrationRequests/" + input.requestId,
  );
  const previousDeviceReference = firestore.doc(
    "users/" + input.userId + "/devices/" + input.previousDeviceId,
  );

  const result = await firestore.runTransaction(async (transaction) => {
    const requestSnapshot = await transaction.get(requestReference);
    const oldSnapshot = await transaction.get(previousDeviceReference);

    if (!requestSnapshot.exists) throw new Error("New request not found.");
    if (!oldSnapshot.exists) throw new Error("Previous device not found.");

    const request = requestSnapshot.data() ?? {};
    const oldDevice = oldSnapshot.data() ?? {};

    if (
      request.schemaVersion !== 1 ||
      request.status !== "pending" ||
      request.userId !== input.userId ||
      request.requestId !== input.requestId
    ) {
      throw new Error("New request is not replaceable.");
    }
    if (oldDevice.userId !== input.userId || oldDevice.status !== "approved") {
      throw new Error("Previous device is not active.");
    }

    const newDeviceId = requiredSegment(request.deviceId, "deviceId");
    if (newDeviceId === input.previousDeviceId) {
      throw new Error("Replacement device must differ.");
    }

    const newDeviceReference = firestore.doc(
      "users/" + input.userId + "/devices/" + newDeviceId,
    );
    const existingNew = await transaction.get(newDeviceReference);
    if (existingNew.exists) throw new Error("Replacement replay rejected.");

    const publicKey = requiredSegment(request.publicKey, "publicKey");
    const platform = requiredSegment(request.platform, "platform");
    const keyVersion = request.keyVersion;
    if (!Number.isInteger(keyVersion) || (keyVersion as number) < 1) {
      throw new Error("Invalid key version.");
    }

    transaction.create(newDeviceReference, {
      schemaVersion: 1,
      userId: input.userId,
      deviceId: newDeviceId,
      publicKey,
      platform,
      keyVersion,
      status: "approved",
      approved: true,
      revoked: false,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      approvedAt: FieldValue.serverTimestamp(),
      approvedBy: actorUid,
      replacedDeviceId: input.previousDeviceId,
    });
    transaction.update(previousDeviceReference, {
      status: "revoked",
      approved: false,
      revoked: true,
      revokedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      revokedBy: actorUid,
      revocationReason: input.reason,
      replacedByDeviceId: newDeviceId,
    });
    transaction.update(requestReference, {
      status: "approved",
      resolvedAt: FieldValue.serverTimestamp(),
      resolvedBy: actorUid,
      replacementForDeviceId: input.previousDeviceId,
    });

    return Object.freeze({
      userId: input.userId,
      requestId: input.requestId,
      newDeviceId,
      previousDeviceId: input.previousDeviceId,
      status: "replaced",
    });
  });

  await writeAudit(firestore, actorUid, "device_replaced", input.userId, {
    requestId: input.requestId,
    newDeviceId: result.newDeviceId,
    previousDeviceId: input.previousDeviceId,
    reason: input.reason,
  });

  return result;
}
