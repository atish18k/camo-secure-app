import assert from "node:assert/strict";
import test from "node:test";
import {
  CamoAuthorizationDocument,
  CamoAuthorizationDocumentReader,
} from "../infrastructure/authorization_document_reader";
import {FirestoreCamoMessageLifecycleAuthorizationPort} from "../validators/firestore_message_lifecycle_authorization_port";

const decodeContext = Object.freeze({
  requestId: "request-1", operationId: "operation-1",
  userId: "user-2", deviceId: "device-2", operationType: "decode" as const,
  pairId: "pair-1", messageId: "message-1", keyPurpose: "messageDecryption",
  keyScope: "message", requiredEntitlements: ["baseDecoding"],
  requestedAt: "2026-07-17T00:00:00.000Z",
  serverReceivedAt: "2026-07-17T00:00:01.000Z",
});

class Reader implements CamoAuthorizationDocumentReader {
  constructor(private readonly value: CamoAuthorizationDocument | null) {}
  async readDocument(path: string): Promise<CamoAuthorizationDocument | null> {
    assert.equal(path, "messagePolicies/message-1");
    return this.value;
  }
}

function active(overrides: CamoAuthorizationDocument = {}): CamoAuthorizationDocument {
  return Object.freeze({schemaVersion: 1, messageId: "message-1", pairId: "pair-1",
    senderUserId: "user-1", senderDeviceId: "device-1", state: "active",
    validity: "five_minutes", oneTimeView: false, policyVersion: 1,
    requiredPolicyVersion: 1, createdAt: "2026-07-17T00:00:00.000Z",
    updatedAt: "2026-07-17T00:00:00.000Z",
    expiresAt: "2026-07-17T00:05:00.000Z", ...overrides});
}

test("active unexpired bound message allows decode", async () => {
  const result = await new FirestoreCamoMessageLifecycleAuthorizationPort(
    new Reader(active()), () => new Date("2026-07-17T00:04:59.999Z"),
  ).validateMessageLifecycle(decodeContext);
  assert.equal(result.allowed, true);
});

test("expiry boundary denies even when stored state is active", async () => {
  const result = await new FirestoreCamoMessageLifecycleAuthorizationPort(
    new Reader(active()), () => new Date("2026-07-17T00:05:00.000Z"),
  ).validateMessageLifecycle(decodeContext);
  assert.deepEqual(result, {allowed: false, reasonCode: "server_message_expired"});
});

for (const state of ["consumed", "revoked", "deleted", "burned", "blocked"]) {
  test(`${state} message denies decode`, async () => {
    const result = await new FirestoreCamoMessageLifecycleAuthorizationPort(
      new Reader(active({state})), () => new Date("2026-07-17T00:01:00.000Z"),
    ).validateMessageLifecycle(decodeContext);
    assert.equal(result.allowed, false);
    assert.equal(result.reasonCode, `server_message_${state}`);
  });
}

test("missing policy and mismatched pair fail closed", async () => {
  const missing = await new FirestoreCamoMessageLifecycleAuthorizationPort(
    new Reader(null),
  ).validateMessageLifecycle(decodeContext);
  assert.equal(missing.allowed, false);
  const mismatch = await new FirestoreCamoMessageLifecycleAuthorizationPort(
    new Reader(active({pairId: "pair-other"})),
  ).validateMessageLifecycle(decodeContext);
  assert.equal(mismatch.allowed, false);
});

test("unlimited requires no expiresAt", async () => {
  const document: Record<string, unknown> = {
    ...active(),
    validity: "unlimited",
  };
  delete document.expiresAt;
  const result = await new FirestoreCamoMessageLifecycleAuthorizationPort(
    new Reader(document),
  ).validateMessageLifecycle(decodeContext);
  assert.equal(result.allowed, true);
});

test("encode does not require a pre-existing message policy", async () => {
  const result = await new FirestoreCamoMessageLifecycleAuthorizationPort(
    new Reader(null),
  ).validateMessageLifecycle({...decodeContext, operationType: "encode"});
  assert.equal(result.allowed, true);
});