import assert from "node:assert/strict";
import test from "node:test";

import {
  DefaultCamoCrc32cCalculator,
} from "../kms/camo_crc32c_calculator";

const calculator =
  new DefaultCamoCrc32cCalculator();

test("CRC32C matches standard check value", () => {
  const value = Uint8Array.from(
    Buffer.from("123456789", "utf8"),
  );

  assert.equal(
    calculator.calculate(value),
    "3808858755",
  );
});

test("CRC32C verifies correct decimal checksum", () => {
  const value = Uint8Array.from(
    Buffer.from("CAMO", "utf8"),
  );

  const checksum =
    calculator.calculate(value);

  assert.equal(
    calculator.verify(value, checksum),
    true,
  );
});

test("CRC32C rejects malformed checksum", () => {
  const value = Uint8Array.from([1, 2, 3]);

  assert.equal(
    calculator.verify(value, "invalid"),
    false,
  );
});

test("CRC32C rejects out-of-range checksum", () => {
  const value = Uint8Array.from([1, 2, 3]);

  assert.equal(
    calculator.verify(
      value,
      "4294967296",
    ),
    false,
  );
});

test("CRC32C detects changed data", () => {
  const original = Uint8Array.from([1, 2, 3]);
  const changed = Uint8Array.from([1, 2, 4]);

  const checksum =
    calculator.calculate(original);

  assert.equal(
    calculator.verify(changed, checksum),
    false,
  );
});