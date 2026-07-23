import assert from "node:assert/strict";
import test from "node:test";
import {
  FailClosedCamoAuthorizationResponseSignerV2,
} from "../security/fail_closed_authorization_response_signer_v2";
import {
  FailClosedCamoKmsAuthorizationService,
} from "../security/fail_closed_kms_authorization_service";

test("fail-closed KMS never releases a key", async () => {
  const result = await new FailClosedCamoKmsAuthorizationService()
    .authorizeKeyRelease({
      requestId: "request",
      operationId: "operation",
      userId: "user",
      deviceId: "device",
      payloadDigest:
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      operationType: "encode",
      pairId: "pair",
      messageId: "message",
      keyPurpose: "messageEncryption",
      keyScope: "message",
      requiredEntitlements: ["baseEncoding"],
      requestedAt: "2026-07-23T00:00:00.000Z",
      serverReceivedAt: "2026-07-23T00:00:01.000Z",
    });
  assert.equal(result.permitted, false);
  assert.equal(result.keyReference, "");
});

test("fail-closed V2 signer never produces a signature", async () => {
  const signer = new FailClosedCamoAuthorizationResponseSignerV2();
  await assert.rejects(
    signer.sign({
      schemaVersion: 2,
      canonicalizationVersion: "CAMO_AUTHORIZATION_V2",
      requestId: "request",
      authorized: true,
      authorizationId: "authorization",
      operationId: "operation",
      challengeId: "challenge",
      userId: "user",
      deviceId: "device",
      pairId: "pair",
      messageId: "message",
      payloadDigest:
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      keyReleaseId: "release",
      keyReference: "key",
      sessionId: "session",
      serverShareId: "share",
      serverShareVersion: 1,
      serverShareBase64: "AQ==",
      serverShareExpiresAt: "2026-07-23T00:01:00.000Z",
      issuedAt: "2026-07-23T00:00:00.000Z",
      expiresAt: "2026-07-23T00:01:00.000Z",
      reasonCode: "server_authorization_granted",
    }),
    /production_authorization_response_signer_v2_unavailable/,
  );
});