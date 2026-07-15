import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import test from "node:test";

import {
  canonicalizeAuthorizationResponse,
} from "../security/authorization_canonicalizer";

const expectedCanonicalPayload = [
  "schemaVersion=1",
  "canonicalizationVersion=CAMO_AUTHORIZATION_V1",
  "requestId=request-001",
  "authorized=true",
  "authorizationId=authorization-001",
  "operationId=operation-001",
  "challengeId=challenge-001",
  "userId=user-001",
  "deviceId=device-001",
  "pairId=pair-001",
  "messageId=",
  "keyReleaseId=release-001",
  "keyReference=key-001",
  "sessionId=session-001",
  "issuedAt=2026-07-13T12:00:00.000Z",
  "expiresAt=2026-07-13T12:01:00.000Z",
  "reasonCode=server_authorization_granted",
].join("\n");

const expectedSha256 =
  "44a93a222988e68fb1667675c7e266b8a" +
  "7fd0c3b16f2b8a1129247b2be634587";

test("server canonical payload matches Version-1 golden bytes", () => {
  const canonical = canonicalizeAuthorizationResponse({
    schemaVersion: 1,
    canonicalizationVersion: "CAMO_AUTHORIZATION_V1",
    requestId: "request-001",
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
  });

  assert.equal(canonical, expectedCanonicalPayload);

  const digest = createHash("sha256")
    .update(canonical, "utf8")
    .digest("hex");

  assert.equal(digest, expectedSha256);
});