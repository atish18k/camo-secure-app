import assert from "node:assert/strict";
import test from "node:test";

import {
  CamoCloudKmsClient,
} from "../kms/camo_cloud_kms_client";
import {
  DefaultCamoCrc32cCalculator,
} from "../kms/camo_crc32c_calculator";
import {
  createCamoCloudKmsProductionAdapters,
} from "../kms/cloud_kms_production_adapter_factory";

const fakeClient: CamoCloudKmsClient = {
  asymmetricSign: async () => {
    throw new Error("not called");
  },

  getPublicKey: async () => {
    throw new Error("not called");
  },

  getKeyVersion: async () => {
    throw new Error("not called");
  },
};

test("factory uses injected client without metadata lookup", () => {
  const result =
    createCamoCloudKmsProductionAdapters({
      keyVersionName:
        "projects/camo-b3cab/locations/global/" +
        "keyRings/camo-enterprise/cryptoKeys/" +
        "authorization-signing/cryptoKeyVersions/1",

      crc32c:
        new DefaultCamoCrc32cCalculator(),

      client: fakeClient,

      releaseIdGenerator:
        () => "release-001",
    });

  assert.ok(result.signer);
  assert.ok(result.keyAuthorizationService);
  assert.ok(result.publicKeyMetadataProvider);
  assert.ok(result.inspector);
});