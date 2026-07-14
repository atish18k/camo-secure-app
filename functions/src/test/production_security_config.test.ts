import assert from "node:assert/strict";
import test from "node:test";

import {
  camoProductionSecurityConfig,
} from "../config/production_security_config";

test("production security configuration is region and identity locked", () => {
  assert.equal(
    camoProductionSecurityConfig.region,
    "asia-south1",
  );

  assert.equal(
    camoProductionSecurityConfig.runtimeServiceAccount,
    "camo-authorization-runtime@camo-b3cab.iam.gserviceaccount.com",
  );

  assert.equal(
    camoProductionSecurityConfig.kmsKeyVersionName,
    "projects/camo-b3cab/locations/asia-south1/keyRings/camo-prod-authz-kr/cryptoKeys/camo-operation-signing/cryptoKeyVersions/1",
  );
});