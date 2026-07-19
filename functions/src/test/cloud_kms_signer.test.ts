import assert from "node:assert/strict";
import test from "node:test";

import {
  CamoCloudKmsClient,
} from "../kms/camo_cloud_kms_client";
import {
  CloudKmsCamoAuthorizationResponseSigner,
  CamoCrc32cCalculator,
} from "../kms/cloud_kms_authorization_response_signer";

const keyName =
  "projects/camo-b3cab/locations/global/" +
  "keyRings/camo-enterprise/cryptoKeys/" +
  "authorization-signing/cryptoKeyVersions/1";

class FakeCrc32c
  implements CamoCrc32cCalculator {
  calculate(
    value: Uint8Array,
  ): string {
    return `crc-${value.length}`;
  }

  verify(
    value: Uint8Array,
    expected: string,
  ): boolean {
    return expected ===
      `crc-${value.length}`;
  }
}

const client: CamoCloudKmsClient = {
  asymmetricSign: async (request) => ({
    name: request.name,
    signature:
      Uint8Array.from([1, 2, 3, 4]),
    signatureCrc32c: "crc-4",
    verifiedDigestCrc32c: true,
  }),

  getPublicKey: async () => {
    throw new Error("not used");
  },

  getKeyVersion: async () => {
    throw new Error("not used");
  },
};

const unsignedResponse = {
  schemaVersion: 1,
  canonicalizationVersion:
    "CAMO_AUTHORIZATION_V1",
  requestId: "request-001",
  payloadDigest: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
  authorized: true,
  authorizationId:
    "authorization-001",
  operationId: "operation-001",
  challengeId: "challenge-001",
  userId: "user-001",
  deviceId: "device-001",
  pairId: "pair-001",
  keyReleaseId: "release-001",
  keyReference: keyName,
  sessionId: "session-001",
  issuedAt:
    "2026-07-13T12:00:00.000Z",
  expiresAt:
    "2026-07-13T12:01:00.000Z",
  reasonCode:
    "server_authorization_granted",
} as const;

test("signer returns verified signature", async () => {
  const signer =
    new CloudKmsCamoAuthorizationResponseSigner(
      client,
      keyName,
      new FakeCrc32c(),
    );

  const result =
    await signer.sign(unsignedResponse);

  assert.equal(
    result.signature,
    "AQIDBA==",
  );

  assert.equal(
    result.signatureAlgorithm,
    "EC_SIGN_P256_SHA256",
  );

  assert.equal(
    result.signatureEncoding,
    "DER_BASE64",
  );

  assert.match(
    result.signingKeyId,
    /authorization-signing:1$/,
  );
});

test("signer rejects signature CRC failure", async () => {
  const invalidClient:
    CamoCloudKmsClient = {
    ...client,

    asymmetricSign:
      async (request) => ({
        name: request.name,
        signature:
          Uint8Array.from([1, 2]),
        signatureCrc32c: "invalid",
        verifiedDigestCrc32c: true,
      }),
  };

  const signer =
    new CloudKmsCamoAuthorizationResponseSigner(
      invalidClient,
      keyName,
      new FakeCrc32c(),
    );

  await assert.rejects(
    signer.sign(unsignedResponse),
    /cloud_kms_signature_integrity_failed/,
  );
});

test("signer rejects denial response", async () => {
  const signer =
    new CloudKmsCamoAuthorizationResponseSigner(
      client,
      keyName,
      new FakeCrc32c(),
    );

  await assert.rejects(
    signer.sign({
      ...unsignedResponse,
      authorized: false,
    }),
    /cloud_kms_refused_unsigned_denial/,
  );
});