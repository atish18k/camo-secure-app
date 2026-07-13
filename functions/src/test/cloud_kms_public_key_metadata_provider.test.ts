import assert from "node:assert/strict";
import test from "node:test";

import {
  CamoCloudKmsClient,
} from "../kms/camo_cloud_kms_client";
import {
  CloudKmsCamoPublicKeyMetadataProvider,
} from "../kms/cloud_kms_public_key_metadata_provider";

const keyName =
  "projects/camo-b3cab/locations/global/" +
  "keyRings/camo-enterprise/cryptoKeys/" +
  "authorization-signing/cryptoKeyVersions/1";

const client:
  CamoCloudKmsClient = {
  asymmetricSign: async () => {
    throw new Error("not used");
  },

  getKeyVersion: async () => {
    throw new Error("not used");
  },

  getPublicKey:
    async (name) => ({
      name,
      pem:
        "-----BEGIN PUBLIC KEY-----\n" +
        "TEST\n" +
        "-----END PUBLIC KEY-----",
      algorithm:
        "EC_SIGN_P256_SHA256",
      pemCrc32c: "12345",
    }),
};

test("public-key metadata is returned", async () => {
  const provider =
    new CloudKmsCamoPublicKeyMetadataProvider(
      client,
    );

  const result =
    await provider.getMetadata(
      keyName,
    );

  assert.equal(
    result.keyVersionName,
    keyName,
  );

  assert.equal(
    result.algorithm,
    "EC_SIGN_P256_SHA256",
  );

  assert.match(
    result.publicKeyPem,
    /BEGIN PUBLIC KEY/,
  );

  assert.match(
    result.signingKeyId,
    /authorization-signing:1$/,
  );
});

test("invalid public-key metadata is rejected", async () => {
  const invalidClient:
    CamoCloudKmsClient = {
    ...client,

    getPublicKey:
      async (name) => ({
        name,
        pem: "",
        algorithm: "",
        pemCrc32c: "",
      }),
  };

  const provider =
    new CloudKmsCamoPublicKeyMetadataProvider(
      invalidClient,
    );

  await assert.rejects(
    provider.getMetadata(keyName),
    /cloud_kms_public_key_metadata_invalid/,
  );
});