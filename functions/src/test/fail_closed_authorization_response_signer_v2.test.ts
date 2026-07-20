import assert from "node:assert/strict";
import test from "node:test";

import {
  CamoUnsignedAuthorizationResponseV2,
} from "../domain/authorization_types_v2";
import {
  FailClosedCamoAuthorizationResponseSignerV2,
} from "../security/fail_closed_authorization_response_signer_v2";

const response: CamoUnsignedAuthorizationResponseV2 = {
  schemaVersion: 2,
  canonicalizationVersion: "CAMO_AUTHORIZATION_V2",
  requestId: "request-001",
  authorized: true,
  authorizationId: "authorization-001",
  operationId: "operation-001",
  challengeId: "challenge-001",
  userId: "user-001",
  deviceId: "device-001",
  pairId: "pair-001",
  messageId: "message-001",
  payloadDigest: "a".repeat(64),
  keyReleaseId: "release-001",
  keyReference: "key-reference-001",
  sessionId: "session-001",
  serverShareId: "share-001",
  serverShareVersion: 1,
  serverShareBase64:
    "BwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwc=",
  serverShareExpiresAt: "2026-07-21T00:01:00.000Z",
  issuedAt: "2026-07-21T00:00:00.000Z",
  expiresAt: "2026-07-21T00:01:00.000Z",
  reasonCode: "server_authorization_granted",
};

test("V2 fail-closed signer never fabricates a signature", async () => {
  const signer =
    new FailClosedCamoAuthorizationResponseSignerV2();

  await assert.rejects(
    signer.sign(response),
    /production_authorization_response_signer_v2_unavailable/,
  );
});