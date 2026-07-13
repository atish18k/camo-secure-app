import assert from "node:assert/strict";
import test from "node:test";

import {
  CamoCloudKmsClient,
} from "../kms/camo_cloud_kms_client";
import {
  DefaultCamoCrc32cCalculator,
} from "../kms/camo_crc32c_calculator";
import {
  CamoCloudKmsKeyVersionInspector,
} from "../kms/cloud_kms_key_version_inspector";
import {
  CloudKmsCamoPublicKeyMetadataProvider,
} from "../kms/cloud_kms_public_key_metadata_provider";
import {
  CamoCloudKmsProductionReadinessProbe,
} from "../readiness/cloud_kms_production_readiness_probe";

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

const pemChecksum =
  calculator.calculate(
    Uint8Array.from(
      Buffer.from(pem, "utf8"),
    ),
  );

const readyClient:
  CamoCloudKmsClient = {
  asymmetricSign: async () => {
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

  getPublicKey:
    async (name) => ({
      name,
      pem,
      algorithm:
        "EC_SIGN_P256_SHA256",
      pemCrc32c: pemChecksum,
    }),
};

test("readiness succeeds only after key and PEM integrity checks", async () => {
  const inspector =
    new CamoCloudKmsKeyVersionInspector(
      readyClient,
    );

  const provider =
    new CloudKmsCamoPublicKeyMetadataProvider(
      readyClient,
      calculator,
    );

  const probe =
    new CamoCloudKmsProductionReadinessProbe(
      keyName,
      inspector,
      provider,
    );

  const result =
    await probe.evaluate();

  assert.equal(result.ready, true);
  assert.equal(result.keyVersionReady, true);
  assert.equal(
    result.publicKeyIntegrityReady,
    true,
  );
});

test("disabled key keeps readiness fail-closed", async () => {
  const disabledClient:
    CamoCloudKmsClient = {
    ...readyClient,

    getKeyVersion:
      async (name) => ({
        name,
        state: "DISABLED",
        algorithm:
          "EC_SIGN_P256_SHA256",
        protectionLevel: "HSM",
      }),
  };

  const probe =
    new CamoCloudKmsProductionReadinessProbe(
      keyName,

      new CamoCloudKmsKeyVersionInspector(
        disabledClient,
      ),

      new CloudKmsCamoPublicKeyMetadataProvider(
        disabledClient,
        calculator,
      ),
    );

  const result =
    await probe.evaluate();

  assert.equal(result.ready, false);
  assert.equal(
    result.reasonCode,
    "cloud_kms_key_version_not_enabled",
  );
});