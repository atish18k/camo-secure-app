import assert from "node:assert/strict";
import test from "node:test";

import {
  cloudKmsSigningKeyId,
  normalizeCloudKmsKeyVersionName,
} from "../kms/cloud_kms_key_version_name";

const validName =
  "projects/camo-b3cab/locations/global/" +
  "keyRings/camo-enterprise/cryptoKeys/" +
  "authorization-signing/cryptoKeyVersions/1";

test("valid key-version name is accepted", () => {
  assert.equal(
    normalizeCloudKmsKeyVersionName(
      validName,
    ),
    validName,
  );
});

test("name without key version is rejected", () => {
  assert.throws(
    () =>
      normalizeCloudKmsKeyVersionName(
        "projects/camo-b3cab/locations/global/" +
        "keyRings/ring/cryptoKeys/key",
      ),
    /cloud_kms_key_version_name_invalid/,
  );
});

test("stable signing key identifier is derived", () => {
  assert.equal(
    cloudKmsSigningKeyId(validName),
    "camo-b3cab:global:camo-enterprise:" +
      "authorization-signing:1",
  );
});