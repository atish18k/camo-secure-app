import assert from "node:assert/strict";
import test from "node:test";
import {
  CamoDomainDecision,
  CamoKmsAuthorizationDecision,
} from "../domain/authorization_types";
import {CamoServerAuthorizationOrchestrator} from "../services/server_authorization_orchestrator";

const allow = (): Promise<CamoDomainDecision> =>
  Promise.resolve({allowed: true, reasonCode: "allowed"});

test("message lifecycle denial stops before policy KMS replay and signing", async () => {
  let policyCalls = 0;
  let kmsCalls = 0;
  let replayCalls = 0;
  let signerCalls = 0;
  const orchestrator = new CamoServerAuthorizationOrchestrator({
    userPort: {validateUser: allow},
    devicePort: {validateDevice: allow},
    pairPort: {validatePair: allow},
    messageLifecyclePort: {
      validateMessageLifecycle: async () => ({
        allowed: false,
        reasonCode: "server_message_revoked",
      }),
    },
    policyPort: {evaluatePolicy: async () => {policyCalls++; return allow();}},
    riskPort: {evaluateRisk: allow},
    entitlementPort: {validateEntitlements: allow},
    kmsPort: {authorizeKeyRelease: async (): Promise<CamoKmsAuthorizationDecision> => {
      kmsCalls++; return {permitted: true, releaseId: "release", keyReference: "key", reasonCode: "allowed"};
    }},
    replayStore: {consume: async () => {replayCalls++; return true;}},
    signer: {sign: async (response) => {signerCalls++; return {
      ...response, signatureAlgorithm: "EC_SIGN_P256_SHA256",
      signatureEncoding: "DER_BASE64", signingKeyId: "key", signature: "signature",
    };}},
    idGenerator: () => "identifier",
    clock: () => new Date("2026-07-17T00:00:00.000Z"),
  });
  const result = await orchestrator.authorize({
    requestId: "request", operationId: "operation", userId: "user-2",
    deviceId: "device-2",
    payloadDigest: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", operationType: "decode", pairId: "pair-1",
    messageId: "message-1", keyPurpose: "messageDecryption", keyScope: "message",
    requiredEntitlements: ["baseDecoding"], requestedAt: "2026-07-17T00:00:00.000Z",
    serverReceivedAt: "2026-07-17T00:00:01.000Z",
  });
  assert.deepEqual(result, {authorized: false, reasonCode: "server_message_revoked"});
  assert.equal(policyCalls, 0); assert.equal(kmsCalls, 0);
  assert.equal(replayCalls, 0); assert.equal(signerCalls, 0);
});