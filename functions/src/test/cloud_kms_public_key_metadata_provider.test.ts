import assert from "node:assert/strict";
import test from "node:test";

import {
  CamoCloudKmsClient,
} from "../kms/camo_cloud_kms_client";
import {
  DefaultCamoCrc32cCalculator,
} from "../kms/camo_crc32c_calculator";
import {
  CloudKmsCamoPublicKeyMetadataProvider,
} from "../kms/cloud_kms_public_key_metadata_provider";

const keyName =
  "projects/camo-b3cab/locations/global/" +
  "keyRings/camo-enterprise/cryptoKeys/" +
  "authorization-signing/cryptoKeyVersions/1";

const pem =
  "-----BEGIN PUBLIC KEY-----\n" +
  "TEST\n" +
  "-----END PUBLIC KEY-----";

const calculator =
  new DefaultCamoCrc32cCalculator();

const validPemCrc32c =
  calculator.calculate(
    Uint8Array.from(
      Buffer.from(pem, "utf8"),
    ),
  );

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
      pem,
      algorithm:
        "EC_SIGN_P256_SHA256",
      pemCrc32c:
        validPemCrc32c,
    }),
};

test("integrity-verified public-key metadata is returned", async () => {
  const provider =
    new CloudKmsCamoPublicKeyMetadataProvider(
      client,
      calculator,
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
    result.publicKeyPemCrc32c,
    validPemCrc32c,
  );

  assert.match(
    result.publicKeyPem,
    /BEGIN PUBLIC KEY/,
  );
});

test("public-key checksum mismatch is rejected", async () => {
  const invalidClient:
    CamoCloudKmsClient = {
    ...client,

    getPublicKey:
      async (name) => ({
        name,
        pem,
        algorithm:
          "EC_SIGN_P256_SHA256",
        pemCrc32c: "1",
      }),
  };

  const provider =
    new CloudKmsCamoPublicKeyMetadataProvider(
      invalidClient,
      calculator,
    );

  await assert.rejects(
    provider.getMetadata(keyName),
    /cloud_kms_public_key_integrity_failed/,
  );
});

test("incomplete public-key metadata is rejected", async () => {
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
      calculator,
    );

  await assert.rejects(
    provider.getMetadata(keyName),
    /cloud_kms_public_key_metadata_invalid/,
  );
});