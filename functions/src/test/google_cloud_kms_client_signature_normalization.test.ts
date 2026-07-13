import assert from "node:assert/strict";
import test from "node:test";

import {
  normalizeCloudKmsBinaryValue,
} from "../kms/google_cloud_kms_client";

test("Uint8Array signature is normalized", () => {
  const result =
    normalizeCloudKmsBinaryValue(
      Uint8Array.from([1, 2, 3]),
    );

  assert.deepEqual(
    Array.from(result),
    [1, 2, 3],
  );
});

test("Buffer signature is normalized", () => {
  const result =
    normalizeCloudKmsBinaryValue(
      Buffer.from([4, 5, 6]),
    );

  assert.deepEqual(
    Array.from(result),
    [4, 5, 6],
  );
});

test("Base64 string signature is decoded", () => {
  const result =
    normalizeCloudKmsBinaryValue(
      "AQIDBA==",
    );

  assert.deepEqual(
    Array.from(result),
    [1, 2, 3, 4],
  );
});

test("empty string signature is rejected", () => {
  assert.throws(
    () =>
      normalizeCloudKmsBinaryValue("   "),
    /cloud_kms_binary_value_empty/,
  );
});

test("empty binary signature is rejected", () => {
  assert.throws(
    () =>
      normalizeCloudKmsBinaryValue(
        Uint8Array.from([]),
      ),
    /cloud_kms_binary_value_empty/,
  );
});