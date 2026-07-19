import assert from "node:assert/strict";
import test from "node:test";

import {
  canonicalizeAuthorizationResponse,
} from "../security/authorization_canonicalizer";

test("canonical response has deterministic ordered fields", () => {
  const result = canonicalizeAuthorizationResponse({
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

  assert.match(result, /^schemaVersion=1\n/);
  assert.match(
    result,
    /canonicalizationVersion=CAMO_AUTHORIZATION_V1/,
  );
  assert.match(result, /requestId=request-001/);
  assert.match(result, /authorized=true/);
  assert.match(result, /authorizationId=authorization-001/);
  assert.match(result, /messageId=\n/);
  assert.match(
    result,
    /reasonCode=server_authorization_granted$/,
  );
});