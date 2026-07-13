import assert from "node:assert/strict";
import test from "node:test";

import {
  CamoCrc32cCalculator,
} from "../kms/cloud_kms_authorization_response_signer";
import {
  createCamoCloudKmsProductionAdapters,
} from "../kms/cloud_kms_production_adapter_factory";

const crc32c:
  CamoCrc32cCalculator = {
  calculate: () => "0",
  verify: () => false,
};

test("factory creates concrete inactive adapters", () => {
  const result =
    createCamoCloudKmsProductionAdapters({
      keyVersionName:
        "projects/camo-b3cab/locations/global/" +
        "keyRings/camo-enterprise/cryptoKeys/" +
        "authorization-signing/cryptoKeyVersions/1",

      crc32c,

      releaseIdGenerator:
        () => "release-001",
    });

  assert.ok(result.signer);

  assert.ok(
    result.keyAuthorizationService,
  );

  assert.ok(
    result.publicKeyMetadataProvider,
  );

  assert.ok(result.inspector);
});