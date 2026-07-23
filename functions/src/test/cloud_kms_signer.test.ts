import assert from "node:assert/strict";
import test from "node:test";
import {CamoCloudKmsClient} from "../kms/camo_cloud_kms_client";
import {CamoCrc32cCalculator} from "../kms/camo_crc32c_calculator";
import {
  CloudKmsCamoAuthorizationResponseSignerV2,
} from "../kms/cloud_kms_authorization_response_signer_v2";

class FakeCrc32c implements CamoCrc32cCalculator {
  calculate(value: Uint8Array): string {
    return `crc-${value.length}`;
  }
  verify(value: Uint8Array, expected: string): boolean {
    return expected === `crc-${value.length}`;
  }
}

const keyName =
  "projects/camo-b3cab/locations/global/keyRings/camo-enterprise/" +
  "cryptoKeys/authorization-signing/cryptoKeyVersions/1";
const client: CamoCloudKmsClient = {
  asymmetricSign: async (request) => ({
    name: request.name,
    signature: Uint8Array.from([1, 2, 3, 4]),
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

test("V2 signer returns an integrity-verified signature", async () => {
  const signer = new CloudKmsCamoAuthorizationResponseSignerV2(
    client,
    keyName,
    new FakeCrc32c(),
  );
  const result = await signer.sign({
    schemaVersion: 2,
    canonicalizationVersion: "CAMO_AUTHORIZATION_V2",
    requestId: "request",
    authorized: true,
    authorizationId: "authorization",
    operationId: "operation",
    challengeId: "challenge",
    userId: "user",
    deviceId: "device",
    pairId: "pair",
    messageId: "message",
    payloadDigest:
      "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    keyReleaseId: "release",
    keyReference: keyName,
    sessionId: "session",
    serverShareId: "share",
    serverShareVersion: 1,
    serverShareBase64: "AQ==",
    serverShareExpiresAt: "2026-07-23T00:01:00.000Z",
    issuedAt: "2026-07-23T00:00:00.000Z",
    expiresAt: "2026-07-23T00:01:00.000Z",
    reasonCode: "server_authorization_granted",
  });
  assert.equal(result.schemaVersion, 2);
  assert.equal(result.signature, "AQIDBA==");
});