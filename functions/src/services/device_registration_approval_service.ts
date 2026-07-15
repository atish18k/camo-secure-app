import {
  FieldValue,
  Firestore,
} from "firebase-admin/firestore";

export interface DeviceApprovalInput {
  readonly userId: string;
  readonly requestId: string;
}

export interface DeviceApprovalResult {
  readonly userId: string;
  readonly requestId: string;
  readonly deviceId: string;
  readonly status: "approved";
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

export function parseDeviceApprovalInput(value: unknown): DeviceApprovalInput {
  if (value === null || typeof value !== "object" || Array.isArray(value)) {
    throw new Error("Invalid device approval payload.");
  }
  const record = value as Record<string, unknown>;
  return Object.freeze({
    userId: requiredSegment(record.userId, "userId"),
    requestId: requiredSegment(record.requestId, "requestId"),
  });
}

function requiredString(record: Record<string, unknown>, name: string): string {
  const value = record[name];
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error("Registration request " + name + " is invalid.");
  }
  return value.trim();
}

export async function approveDeviceRegistration(
  firestore: Firestore,
  input: DeviceApprovalInput,
  approverUid: string,
): Promise<DeviceApprovalResult> {
  const approvedBy = requiredSegment(approverUid, "approverUid");
  const requestPath = "users/" + input.userId +
    "/deviceRegistrationRequests/" + input.requestId;
  const requestReference = firestore.doc(requestPath);

  return firestore.runTransaction(async (transaction) => {
    const requestSnapshot = await transaction.get(requestReference);
    if (!requestSnapshot.exists) {
      throw new Error("Device registration request does not exist.");
    }
    const request = requestSnapshot.data() as Record<string, unknown>;
    if (
      request.schemaVersion !== 1 ||
      request.status !== "pending" ||
      request.userId !== input.userId ||
      request.requestId !== input.requestId
    ) {
      throw new Error("Device registration request is not approvable.");
    }
    const deviceId = requiredSegment(request.deviceId, "deviceId");
    const publicKey = requiredString(request, "publicKey");
    const platform = requiredString(request, "platform");
    const keyVersion = request.keyVersion;
    if (!Number.isInteger(keyVersion) || (keyVersion as number) < 1) {
      throw new Error("Device key version is invalid.");
    }
    const deviceReference = firestore.doc(
      "users/" + input.userId + "/devices/" + deviceId,
    );
    const existingDevice = await transaction.get(deviceReference);
    if (existingDevice.exists) {
      throw new Error("Device approval replay or overwrite was rejected.");
    }
    transaction.create(deviceReference, {
      schemaVersion: 1,
      deviceId,
      userId: input.userId,
      publicKey,
      keyVersion,
      platform,
      status: "approved",
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      approvedAt: FieldValue.serverTimestamp(),
      approvedBy,
      approved: true,
      revoked: false,
    });
    transaction.update(requestReference, {
      status: "approved",
      resolvedAt: FieldValue.serverTimestamp(),
      resolvedBy: approvedBy,
    });
    return Object.freeze({
      userId: input.userId,
      requestId: input.requestId,
      deviceId,
      status: "approved" as const,
    });
  });
}