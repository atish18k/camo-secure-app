import assert from "node:assert/strict";
import test from "node:test";

import {
  NodeCryptoCamoServerShareGenerator,
} from "../security/server_share_generator";

test("generator creates unique operation-bound 32-byte ServerShares", () => {
  const generator = new NodeCryptoCamoServerShareGenerator();
  const issuedAt = new Date("2026-07-21T00:00:00.000Z");
  const authorizationExpiresAt =
    new Date("2026-07-21T00:01:00.000Z");

  const first = generator.generate({
    operationId: "operation-001",
    issuedAt,
    authorizationExpiresAt,
  });

  const second = generator.generate({
    operationId: "operation-001",
    issuedAt,
    authorizationExpiresAt,
  });

  assert.equal(first.operationId, "operation-001");
  assert.equal(first.version, 1);
  assert.equal(first.bytes.length, 32);
  assert.equal(Buffer.from(first.base64, "base64").length, 32);
  assert.equal(first.expiresAt, authorizationExpiresAt.toISOString());
  assert.notEqual(first.shareId, second.shareId);
  assert.notEqual(first.base64, second.base64);
});

test("generator fails closed for invalid operation or expiry", () => {
  const generator = new NodeCryptoCamoServerShareGenerator();
  const issuedAt = new Date("2026-07-21T00:00:00.000Z");

  assert.throws(
    () => generator.generate({
      operationId: " ",
      issuedAt,
      authorizationExpiresAt:
        new Date("2026-07-21T00:01:00.000Z"),
    }),
    /server_share_operation_id_required/,
  );

  assert.throws(
    () => generator.generate({
      operationId: "operation-001",
      issuedAt,
      authorizationExpiresAt: issuedAt,
    }),
    /server_share_expiry_invalid/,
  );
});