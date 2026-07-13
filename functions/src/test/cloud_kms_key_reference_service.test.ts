import assert from "node:assert/strict";
import test from "node:test";

import {
  CamoCloudKmsClient,
} from "../kms/camo_cloud_kms_client";
import {
  CloudKmsCamoKeyReferenceAuthorizationService,
} from "../kms/cloud_kms_key_reference_authorization_service";
import {
  CamoCloudKmsKeyVersionInspector,
} from "../kms/cloud_kms_key_version_inspector";

const keyName =
  "projects/camo-b3cab/locations/global/" +
  "keyRings/camo-enterprise/cryptoKeys/" +
  "authorization-signing/cryptoKeyVersions/1";

const baseClient:
  CamoCloudKmsClient = {
  asymmetricSign: async () => {
    throw new Error("not used");
  },

  getPublicKey: async () => {
    throw new Error("not used");
  },

  getKeyVersion:
    async (name) => ({
      name,
      state: "ENABLED",
      algorithm:
        "EC_SIGN_P256_SHA256",
      protectionLevel: "HSM",
    }),
};

const context = {
  requestId: "request-001",
  operationId: "operation-001",
  userId: "user-001",
  deviceId: "device-001",
  operationType: "encode" as const,
  pairId: "pair-001",
  keyPurpose:
    "messageEncryption",
  keyScope: "message",
  requiredEntitlements: [
    "baseEncoding",
  ],
  requestedAt:
    "2026-07-13T12:00:00.000Z",
  serverReceivedAt:
    "2026-07-13T12:00:01.000Z",
};

test("enabled KMS key authorizes reference", async () => {
  const service =
    new CloudKmsCamoKeyReferenceAuthorizationService(
      new CamoCloudKmsKeyVersionInspector(
        baseClient,
      ),
      keyName,
      () => "release-001",
    );

  const result =
    await service.authorizeKeyRelease(
      context,
    );

  assert.equal(
    result.permitted,
    true,
  );

  assert.equal(
    result.releaseId,
    "release-001",
  );

  assert.equal(
    result.keyReference,
    keyName,
  );
});

test("disabled key fails closed", async () => {
  const disabledClient:
    CamoCloudKmsClient = {
    ...baseClient,

    getKeyVersion:
      async (name) => ({
        name,
        state: "DISABLED",
        algorithm:
          "EC_SIGN_P256_SHA256",
        protectionLevel: "HSM",
      }),
  };

  const service =
    new CloudKmsCamoKeyReferenceAuthorizationService(
      new CamoCloudKmsKeyVersionInspector(
        disabledClient,
      ),
      keyName,
      () => "release-001",
    );

  const result =
    await service.authorizeKeyRelease(
      context,
    );

  assert.equal(
    result.permitted,
    false,
  );

  assert.equal(
    result.reasonCode,
    "cloud_kms_key_version_not_enabled",
  );
});

test("empty release identifier fails closed", async () => {
  const service =
    new CloudKmsCamoKeyReferenceAuthorizationService(
      new CamoCloudKmsKeyVersionInspector(
        baseClient,
      ),
      keyName,
      () => "   ",
    );

  const result =
    await service.authorizeKeyRelease(
      context,
    );

  assert.equal(
    result.permitted,
    false,
  );

  assert.equal(
    result.reasonCode,
    "cloud_kms_release_identifier_invalid",
  );
});