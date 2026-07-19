import assert from "node:assert/strict";
import test from "node:test";

import {
  CamoDomainDecision,
  CamoServerAuthorizationContext,
  CamoUnsignedAuthorizationResponse,
} from "../domain/authorization_types";
import {
  canonicalizeAuthorizationResponse,
} from "../security/authorization_canonicalizer";
import {
  CamoServerAuthorizationOrchestrator,
} from "../services/server_authorization_orchestrator";

function allow(): Promise<CamoDomainDecision> {
  return Promise.resolve({
    allowed: true,
    reasonCode: "allowed",
  });
}

test("signed contract binds schema and request identity", async () => {
  const context: CamoServerAuthorizationContext = {
    requestId: "request-v1-001",
    operationId: "operation-v1-001",
    userId: "user-v1-001",
    deviceId: "device-v1-001",
    payloadDigest: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    operationType: "encode",
    pairId: "pair-v1-001",
    keyPurpose: "messageEncryption",
    keyScope: "message",
    requiredEntitlements: ["baseEncoding"],
    requestedAt: "2026-07-14T12:00:00.000Z",
    serverReceivedAt: "2026-07-14T12:00:01.000Z",
  };

  let unsignedResponse:
    CamoUnsignedAuthorizationResponse | undefined;

  let identifier = 0;

  const orchestrator =
    new CamoServerAuthorizationOrchestrator({
      userPort: {validateUser: allow},
      devicePort: {validateDevice: allow},
      pairPort: {validatePair: allow},
      messageLifecyclePort: {validateMessageLifecycle: allow},
      policyPort: {evaluatePolicy: allow},
      riskPort: {evaluateRisk: allow},
      entitlementPort: {validateEntitlements: allow},
      kmsPort: {
        authorizeKeyRelease: async () => ({
          permitted: true,
          releaseId: "release-v1-001",
          keyReference: "key-v1-001",
          reasonCode: "allowed",
        }),
      },
      replayStore: {
        consume: async () => true,
      },
      signer: {
        sign: async (response) => {
          unsignedResponse = response;

          return {
            ...response,
            signatureAlgorithm:
              "EC_SIGN_P256_SHA256",
            signatureEncoding: "DER_BASE64",
            signingKeyId: "camo-operation-signing:1",
            signature: "der-signature-base64",
          };
        },
      },
      idGenerator: () => {
        identifier += 1;
        return `identifier-${identifier}`;
      },
      clock: () =>
        new Date("2026-07-14T12:00:02.000Z"),
    });

  const result = await orchestrator.authorize(context);

  assert.equal(result.authorized, true);
  assert.ok(unsignedResponse);
  assert.equal(unsignedResponse.schemaVersion, 1);
  assert.equal(
    unsignedResponse.canonicalizationVersion,
    "CAMO_AUTHORIZATION_V1",
  );
  assert.equal(
    unsignedResponse.requestId,
    context.requestId,
  );

  const canonical =
    canonicalizeAuthorizationResponse(
      unsignedResponse,
    );

  assert.match(canonical, /^schemaVersion=1\n/);
  assert.match(
    canonical,
    /canonicalizationVersion=CAMO_AUTHORIZATION_V1/,
  );
  assert.match(
    canonical,
    /requestId=request-v1-001/,
  );
});