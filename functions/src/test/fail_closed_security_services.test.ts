import assert from "node:assert/strict";
import test from "node:test";

import {
  FailClosedCamoAuthorizationResponseSigner,
} from "../security/fail_closed_authorization_response_signer";
import {
  FailClosedCamoKmsAuthorizationService,
} from "../security/fail_closed_kms_authorization_service";

const context = {
  requestId: "request-001",
  operationId: "operation-001",
  userId: "user-001",
  deviceId: "device-001",
  operationType: "encode" as const,
  pairId: "pair-001",
  keyPurpose: "messageEncryption",
  keyScope: "message",
  requiredEntitlements: ["baseEncoding"],
  requestedAt: "2026-07-13T12:00:00.000Z",
  serverReceivedAt: "2026-07-13T12:00:01.000Z",
};

test("fail-closed KMS never releases a key", async () => {
  const service = new FailClosedCamoKmsAuthorizationService();
  const result = await service.authorizeKeyRelease(context);

  assert.equal(result.permitted, false);
  assert.equal(result.keyReference, "");
  assert.equal(result.reasonCode, "production_kms_unavailable");
});

test("fail-closed signer never produces a signature", async () => {
  const signer = new FailClosedCamoAuthorizationResponseSigner();

  await assert.rejects(
    signer.sign({
      authorized: true,
      authorizationId: "authorization-001",
      operationId: "operation-001",
      challengeId: "challenge-001",
      userId: "user-001",
      deviceId: "device-001",
      pairId: "pair-001",
      keyReleaseId: "release-001",
      keyReference: "key-001",
      sessionId: "session-001",
      issuedAt: "2026-07-13T12:00:00.000Z",
      expiresAt: "2026-07-13T12:01:00.000Z",
      reasonCode: "server_authorization_granted",
    }),
    /production_authorization_response_signer_unavailable/,
  );
});