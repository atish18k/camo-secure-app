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
  "payloadDigest=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  "keyReleaseId=release-001",
  "keyReference=key-001",
  "sessionId=session-001",
  "issuedAt=2026-07-13T12:00:00.000Z",
  "expiresAt=2026-07-13T12:01:00.000Z",
  "reasonCode=server_authorization_granted",
].join("\n");

const expectedSha256 =
  "569ef4396fd33e940541c7de07e0043f" +
  "afd762e50ed46c521cb116c5c54d75a8";

test("server canonical payload matches Version-1 golden bytes", () => {
  const canonical = canonicalizeAuthorizationResponse({
    schemaVersion: 1,
    canonicalizationVersion: "CAMO_AUTHORIZATION_V1",
    requestId: "request-001",
    payloadDigest: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
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