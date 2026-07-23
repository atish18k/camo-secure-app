import assert from "node:assert/strict";
import test from "node:test";

import {
  CamoDomainDecision,
  CamoKmsAuthorizationDecision,
} from "../domain/authorization_types";
import {
  CamoServerAuthorizationOrchestratorV2,
} from "../services/server_authorization_orchestrator_v2";

const allow = (): Promise<CamoDomainDecision> =>
  Promise.resolve({allowed: true, reasonCode: "allowed"});

function createOrchestrator() {
  let id = 0;
  return new CamoServerAuthorizationOrchestratorV2({
    userPort: {validateUser: allow},
    devicePort: {validateDevice: allow},
    pairPort: {validatePair: allow},
    messageLifecyclePort: {validateMessageLifecycle: allow},
    policyPort: {evaluatePolicy: allow},
    riskPort: {evaluateRisk: allow},
    entitlementPort: {validateEntitlements: allow},
    kmsPort: {
      authorizeKeyRelease: async (): Promise<CamoKmsAuthorizationDecision> => ({
        permitted: true,
        releaseId: "release",
        keyReference: "key",
        reasonCode: "allowed",
      }),
    },
    replayStore: {consume: async () => true},
    signer: {
      sign: async (response) => ({
        ...response,
        signatureAlgorithm: "EC_SIGN_P256_SHA256",
        signatureEncoding: "DER_BASE64",
        signingKeyId: "signing-key",
        signature: "signature",
      }),
    },
    serverShareGenerator: {
      generate: ({operationId, authorizationExpiresAt}) => ({
        shareId: "share",
        operationId,
        version: 1,
        bytes: Uint8Array.from([1]),
        base64: "AQ==",
        expiresAt: authorizationExpiresAt.toISOString(),
      }),
    },
    idGenerator: () => `identifier-${++id}`,
    clock: () => new Date("2026-07-23T00:00:00.000Z"),
  });
}

const context = {
  requestId: "request",
  operationId: "operation",
  userId: "user",
  deviceId: "device",
  operationType: "decode" as const,
  pairId: "pair",
  messageId: "message",
  keyPurpose: "messageDecryption",
  keyScope: "message",
  requiredEntitlements: ["baseDecoding"],
  requestedAt: "2026-07-23T00:00:00.000Z",
  serverReceivedAt: "2026-07-23T00:00:01.000Z",
  payloadDigest:
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
};

test("V2 orchestrator returns operation-bound signed ServerShare", async () => {
  const result = await createOrchestrator().authorize(context);
  assert.equal(result.authorized, true);
  assert.equal(result.signedResponse?.schemaVersion, 2);
  assert.equal(
    result.signedResponse?.canonicalizationVersion,
    "CAMO_AUTHORIZATION_V2",
  );
  assert.equal(result.signedResponse?.serverShareId, "share");
  assert.equal(result.signedResponse?.serverShareBase64, "AQ==");
  assert.equal(result.signedResponse?.pairId, "pair");
  assert.equal(result.signedResponse?.messageId, "message");
});

test("V2 orchestrator fails closed without pair and message bindings", async () => {
  const result = await createOrchestrator().authorize({
    ...context,
    pairId: undefined,
  });
  assert.deepEqual(result, {
    authorized: false,
    reasonCode: "server_authorization_context_invalid",
  });
});