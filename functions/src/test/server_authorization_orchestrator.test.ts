import assert from "node:assert/strict";
import test from "node:test";

import {
  CamoDomainDecision,
  CamoKmsAuthorizationDecision,
  CamoServerAuthorizationContext,
  CamoSignedAuthorizationResponse,
  CamoUnsignedAuthorizationResponse,
} from "../domain/authorization_types";
import {
  CamoServerAuthorizationOrchestrator,
} from "../services/server_authorization_orchestrator";

const context: CamoServerAuthorizationContext = {
  requestId: "request-001",
  operationId: "operation-001",
  userId: "user-001",
  deviceId: "device-001",
  operationType: "encode",
  pairId: "pair-001",
  keyPurpose: "messageEncryption",
  keyScope: "message",
  requiredEntitlements: ["baseEncoding"],
  requestedAt: "2026-07-13T12:00:00.000Z",
  serverReceivedAt: "2026-07-13T12:00:01.000Z",
};

function allow(): Promise<CamoDomainDecision> {
  return Promise.resolve({
    allowed: true,
    reasonCode: "allowed",
  });
}

test("orchestrator stops at first denied domain", async () => {
  let kmsCalls = 0;
  let signerCalls = 0;
  let replayCalls = 0;

  const orchestrator = new CamoServerAuthorizationOrchestrator({
    userPort: {
      validateUser: () =>
        Promise.resolve({
          allowed: false,
          reasonCode: "user_denied",
        }),
    },
    devicePort: {validateDevice: allow},
    pairPort: {validatePair: allow},
    messageLifecyclePort: {validateMessageLifecycle: allow},
    policyPort: {evaluatePolicy: allow},
    riskPort: {evaluateRisk: allow},
    entitlementPort: {validateEntitlements: allow},
    kmsPort: {
      authorizeKeyRelease: async (): Promise<
        CamoKmsAuthorizationDecision
      > => {
        kmsCalls++;
        return {
          permitted: true,
          releaseId: "release-001",
          keyReference: "key-001",
          reasonCode: "allowed",
        };
      },
    },
    replayStore: {
      consume: async () => {
        replayCalls++;
        return true;
      },
    },
    signer: {
      sign: async (
        response: CamoUnsignedAuthorizationResponse,
      ): Promise<CamoSignedAuthorizationResponse> => {
        signerCalls++;
        return {
          ...response,
          signatureAlgorithm:
            "EC_SIGN_P256_SHA256",
          signatureEncoding: "DER_BASE64",
          signingKeyId: "test-key",
          signature: "test-signature",
        };
      },
    },
    idGenerator: () => "identifier-001",
    clock: () => new Date("2026-07-13T12:00:00.000Z"),
  });

  const result = await orchestrator.authorize(context);

  assert.equal(result.authorized, false);
  assert.equal(result.reasonCode, "user_denied");
  assert.equal(kmsCalls, 0);
  assert.equal(replayCalls, 0);
  assert.equal(signerCalls, 0);
});

test("orchestrator remains denied when KMS is unavailable", async () => {
  let replayCalls = 0;
  let signerCalls = 0;

  const orchestrator = new CamoServerAuthorizationOrchestrator({
    userPort: {validateUser: allow},
    devicePort: {validateDevice: allow},
    pairPort: {validatePair: allow},
    messageLifecyclePort: {validateMessageLifecycle: allow},
    policyPort: {evaluatePolicy: allow},
    riskPort: {evaluateRisk: allow},
    entitlementPort: {validateEntitlements: allow},
    kmsPort: {
      authorizeKeyRelease: async () => ({
        permitted: false,
        releaseId: "",
        keyReference: "",
        reasonCode: "production_kms_unavailable",
      }),
    },
    replayStore: {
      consume: async () => {
        replayCalls++;
        return true;
      },
    },
    signer: {
      sign: async (response) => {
        signerCalls++;
        return {
          ...response,
          signatureAlgorithm:
            "EC_SIGN_P256_SHA256",
          signatureEncoding: "DER_BASE64",
          signingKeyId: "test-key",
          signature: "test-signature",
        };
      },
    },
    idGenerator: () => "identifier-001",
    clock: () => new Date("2026-07-13T12:00:00.000Z"),
  });

  const result = await orchestrator.authorize(context);

  assert.equal(result.authorized, false);
  assert.equal(result.reasonCode, "production_kms_unavailable");
  // MP-016: replay is consumed before the unavailable KMS denies.
  assert.equal(replayCalls, 1);
  assert.equal(signerCalls, 0);
});
