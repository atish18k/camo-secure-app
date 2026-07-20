import assert from "node:assert/strict";
import {
  createHash,
} from "node:crypto";
import test from "node:test";

import {
  CamoUnsignedAuthorizationResponseV2,
} from "../domain/authorization_types_v2";
import {
  canonicalizeAuthorizationResponseV2,
} from "../security/authorization_canonicalizer_v2";

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

test("V2 canonical payload has locked repository-aligned field order", () => {
  const canonical = canonicalizeAuthorizationResponseV2(response);
  const fieldNames = canonical
    .split("\n")
    .map((line) => line.substring(0, line.indexOf("=")));

  assert.deepEqual(fieldNames, [
    "schemaVersion",
    "canonicalizationVersion",
    "requestId",
    "authorized",
    "authorizationId",
    "operationId",
    "challengeId",
    "userId",
    "deviceId",
    "pairId",
    "messageId",
    "payloadDigest",
    "keyReleaseId",
    "keyReference",
    "sessionId",
    "serverShareId",
    "serverShareVersion",
    "serverShareBase64",
    "serverShareExpiresAt",
    "issuedAt",
    "expiresAt",
    "reasonCode",
  ]);

  assert.equal(
    createHash("sha256")
      .update(canonical, "utf8")
      .digest("hex")
      .length,
    64,
  );
});

test("V2 canonicalizer rejects line-break injection", () => {
  assert.throws(
    () => canonicalizeAuthorizationResponseV2({
      ...response,
      serverShareId: "share-001\nforged=true",
    }),
    /server_share_id_contains_line_break/,
  );
});